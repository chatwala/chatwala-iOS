//
//  CWMessageManager.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 Chatwala. All rights reserved.
//

#import "CWMessageManager.h"
#import "AppDelegate.h"
#import "CWMessageCell.h"
#import "CWUserManager.h"
#import "CWDataManager.h"
#import "CWServerAPI.h"
#import "CWPushNotificationsAPI.h"
#import "CWMessagesDownloader.h"
#import "AOFetchUtilities.h"

@interface CWMessageManager ()

@property (nonatomic,assign) BOOL needsOriginalMessageUploadURL;

@property (nonatomic,strong) Message *tempOriginalMessage;
@property (nonatomic,strong) NSString *tempUploadURLString;
@property (nonatomic,strong) AFHTTPRequestOperation *messageIDOperation;

@end

@interface CWMessageManager ()
{
    BOOL useLocalServer;
    NSIndexPath * selectedIndexPath;
    UITableView * messageTable;
}
@end


@implementation CWMessageManager

- (id)init {
    self = [super init];
    if (self) {
        useLocalServer = NO;
        self.needsOriginalMessageUploadURL = YES;
    }
    return self;
}

+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}

- (NSString *)baseEndPoint {
    if (useLocalServer) {
        return @"http://192.168.0.102:1337";
    }

#ifdef USE_QA_SERVER
    return @"https://chatwala-qa-20.azurewebsites.net";
#elif USE_DEV_SERVER
    return @"https://chatwala-deveast-20.azurewebsites.net";
#elif USE_SANDBOX_SERVER
    return @"https://chatwala-sandbox-20.azurewebsites.net";
#elif USE_STAGING_SERVER
    return @"https://chatwala-prodeast-20.azurewebsites.net";
#else
    return @"https://chatwala-prodeast-20.azurewebsites.net";
#endif
    
}

- (NSString *)registerEndPoint {
    return [[self baseEndPoint]stringByAppendingPathComponent:@"register"];
}


- (NSString *)messagesEndPoint {
    return [[self baseEndPoint]stringByAppendingPathComponent:@"messages"];
}

- (NSString *)getInboxEndPoint {
    return [[self baseEndPoint]stringByAppendingString:@"/messages/userInbox"];
}

- (NSString *)getMessageEndPoint {
    return [[self baseEndPoint]stringByAppendingString:@"/messages/%@"];
}


- (void)getMessagesForUser:(NSString *)userID withCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock {
    
    if (![userID length]) {
        return;
    }
    else {
        
        if (![self hasNecessaryDiskSpace]) {
            [SVProgressHUD showErrorWithStatus:@"Please free up disk space. Chatwala needs space to download your messages."];
            return;
        }
        
        [CWServerAPI getInboxForUserID:userID withCompletionBlock:^(NSArray *messages, NSError *error) {
            
            if (error) {
                // TODO;
                self.getMessagesFailureBlock(nil, error);
                
                if (completionBlock) {
                    completionBlock(UIBackgroundFetchResultNoData);
                }
            }
            else {
                
                NSMutableArray *arrayOfMessages = [NSMutableArray arrayWithCapacity:messages.count];
                
                for (NSDictionary *messageMetadata in messages) {
                    NSError *error = nil;
                    Message *newMessage = [[CWDataManager sharedInstance] createMessageWithDictionary:messageMetadata error:&error];
                    [newMessage saveContext];
                    [arrayOfMessages addObject:newMessage];
                }
                
                CWMessagesDownloader *downloader = [[CWMessagesDownloader alloc] init];
                [downloader downloadMessages:arrayOfMessages withCompletionBlock:^(NSArray *messagesDownloaded) {
                    
                    NSLog(@"Messages downloader completed fetches.");
                    
                    // Finished download, now update badge & send local push notification if necessary
                    if (completionBlock) {
                        
                        if ([messagesDownloaded count]) {
                            
                            NSLog(@"New messages downloaded - calling background completion block.");
                            
                            [CWPushNotificationsAPI postCompletedMessageFetchLocalNotification];
                            completionBlock(UIBackgroundFetchResultNewData);
                        }
                        else {
                            NSLog(@"NO New messages downloaded - calling background completion block.");
                            completionBlock(UIBackgroundFetchResultNoData);
                        }
                    }
                    
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[CWUserManager sharedInstance] numberOfTotalUnreadMessages]];
                    [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
                }];
            }
            
        }];
    }
}

- (void)sendCompletionBlock:(void (^)(UIBackgroundFetchResult))completionBlock {
    NSLog(@"Completion block being called");
    
    if (completionBlock) {
        completionBlock(UIBackgroundFetchResultNewData);
    }
}

#pragma mark - Download logic

- (NSArray *)messageIDsFromResponse:(NSArray *)messages {
    
    NSMutableArray *messageIDs = [NSMutableArray array];
    for (NSDictionary * messageDictionary in messages) {
        NSString *currentMessageID = [messageDictionary objectForKey:@"message_id"];
        [messageIDs addObject:currentMessageID];
    }
    
    return messageIDs;
}

- (AFRequestOperationManagerFailureBlock) getMessagesFailureBlock {
    return (^ void(AFHTTPRequestOperation *operation, NSError * error){
        NSLog(@"failed to fetch messages with error: %@",error);
        
        [NC postNotificationName:@"MessagesLoadFailed" object:nil userInfo:nil];
        
    });
}

#pragma mark - MessageID Server Fetches

- (void)fetchUploadURLForReplyMessage:(Message *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock {

    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    NSString *endPoint = [self.messagesEndPoint stringByAppendingString:@"/startReplyMessageSend"];
    
    NSDictionary *params = @{@"user_id" : message.senderID,
                             @"replying_to_message_id" : message.replyToMessageID,
                             @"message_id" : message.messageID,
                             @"start_recording":  message.startRecording};
     
    NSLog(@"Requesting reply message upload URL with params: %@", params);
     
    [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *sasUploadUrl = [responseObject valueForKey:@"write_url"];
        Message *replyMessage = [[CWDataManager sharedInstance] createMessageWithDictionary:[responseObject objectForKey:@"message_meta_data"] error:nil];
        replyMessage.thumbnailUploadURLString = [responseObject objectForKey:@"message_thumbnail_write_url"];
        
        NSLog(@"Fetched reply message upload URL: %@ for messageID: %@", sasUploadUrl, message.messageID);
        if (completionBlock) {
            completionBlock(replyMessage, sasUploadUrl);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed to fetch metadata for reply messageID: %@ with error:%@", message.messageID, error);
        NSLog(@"operation:%@",operation);
        
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    }];
}

- (void)fetchUploadURLForOriginalMessage:(NSString *)userID completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock {
    
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");

    // Check if we already have unused messageID we fetched earlier - return that
    if (!self.needsOriginalMessageUploadURL && self.tempOriginalMessage && self.tempUploadURLString) {
        if (completionBlock) {
            completionBlock(self.tempOriginalMessage,self.tempUploadURLString);
        }
        
        return;
    }
    
    // Cancel & cleanup previous requests
    [self.messageIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.messageIDOperation cancel];
    
    self.tempUploadURLString = nil;
    self.messageIDOperation = nil;
    self.tempOriginalMessage = nil;
    
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *newMessageID = [self generateMessageID];
    NSString *endPoint = [self.messagesEndPoint stringByAppendingString:@"/startUnknownRecipientMessageSend"];
    
    
    NSDictionary *params = @{@"sender_id" : userID,
                             @"message_id" : newMessageID,
                             @"analytics_sender_category" : [CWAnalytics currentCategory]};
    
    NSLog(@"Starting original message send with params: %@", params);
    
    
    self.messageIDOperation = [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.needsOriginalMessageUploadURL = NO;
        self.tempUploadURLString = [responseObject valueForKey:@"write_url"];
        self.tempOriginalMessage = [[CWDataManager sharedInstance] createMessageWithDictionary:[responseObject objectForKey:@"message_meta_data"] error:nil];
        self.tempOriginalMessage.thumbnailUploadURLString = [responseObject objectForKey:@"message_thumbnail_write_url"];
        
        NSLog(@"Fetched original message upload URL: %@: for new original message ID: %@",self.tempUploadURLString, self.tempOriginalMessage.messageID);
        
        if (completionBlock) {
            completionBlock(self.tempOriginalMessage, self.tempUploadURLString);
        }
        
        self.messageIDOperation = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.needsOriginalMessageUploadURL = YES;
        
        NSLog(@"Failed to fetch original message upload ID from the server for a reply with error: %@",error);
        NSLog(@"operation: %@",operation);
        
        if (completionBlock) {
            completionBlock(nil, nil);
        }
        
        self.messageIDOperation = nil;
    }];
}

- (void)clearUploadURLForOriginalMessage {

    // Cancel & cleanup previous requests
    [self.messageIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.messageIDOperation cancel];
    
    self.tempUploadURLString = nil;
    self.messageIDOperation = nil;
    self.tempOriginalMessage = nil;
    
    self.needsOriginalMessageUploadURL = YES;
}

- (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString replyingToMessageOrNil:(Message *)messageBeingRespondedTo {

    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
    
    NSString * endPoint = uploadURLString;
    NSLog(@"uploading message: %@",endPoint);
    
    [CWServerAPI uploadMessage:messageToUpload toURL:endPoint withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error during message upload: %@", error);
        }
        else {
            NSLog(@"Successful message upload - messageID: %@", messageToUpload.messageID);
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                if (messageBeingRespondedTo) {
                    [messageBeingRespondedTo setEMessageViewedState:eMessageViewedStateReplied];
                }
                
                //Background Thread
                [self moveMessageToSentBox:messageToUpload];
            });
            
            // Call finalize
            [CWServerAPI completeMessage:messageToUpload isReply:(messageBeingRespondedTo ? YES : NO)];
        }
    }];
    
    // After this we'll need a different endpoint for upload if we cancel or kill the app
    
    if (!messageBeingRespondedTo) {
        self.needsOriginalMessageUploadURL = YES;
    }
}

- (void)fetchUploadURLForOriginalMessage:(Message *)message toRecipient:(NSString *)recipientID completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock {
    
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    NSString *endPoint = [self.messagesEndPoint stringByAppendingString:@"/startKnownRecipientMessageSend"];
    
    NSDictionary *params = @{@"sender_id" : message.senderID,
                             @"recipient_id" : message.recipientID,
                             @"message_id" : message.messageID,
                             @"analytics_sender_category" : [CWAnalytics currentCategory]};
    
    NSLog(@"Requesting reply message upload URL with params: %@", params);
    
    [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *sasUploadUrl = [responseObject valueForKey:@"write_url"];
        Message *replyMessage = [[CWDataManager sharedInstance] createMessageWithDictionary:[responseObject objectForKey:@"message_meta_data"] error:nil];
        replyMessage.thumbnailUploadURLString = [responseObject objectForKey:@"message_thumbnail_write_url"];
        
        NSLog(@"Fetched reply message upload URL: %@ for messageID: %@", sasUploadUrl, message.messageID);
        if (completionBlock) {
            completionBlock(replyMessage, sasUploadUrl);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed to fetch metadata for reply messageID: %@ with error:%@", message.messageID, error);
        NSLog(@"operation:%@",operation);
        
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    }];
    
}

#pragma mark - Helpers

- (void)moveMessageToSentBox:(Message *)message {

    NSError *error = nil;
    NSString * localPath = [[CWVideoFileCache sharedCache] sentboxDirectoryPathForKey:message.messageID];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating sent file directory: %@", error.debugDescription);
        }
    }
    
    NSURL *destinationURL = [NSURL fileURLWithPath:[[[CWVideoFileCache sharedCache] sentboxDirectoryPathForKey:message.messageID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",message.messageID]]];
    
    [[NSFileManager defaultManager] moveItemAtURL:[Message outboxChatwalaZipURL:message.messageID] toURL:destinationURL error:&error];
    
    [[NSFileManager defaultManager] removeItemAtPath:[[CWVideoFileCache sharedCache] outboxDirectoryPathForKey:message.messageID]  error:nil];
    message.chatwalaZipURL = destinationURL;
}


- (NSString *)generateMessageID {
    return [[[NSUUID UUID] UUIDString] lowercaseString];
}

- (void)clearDiskSpace {
    
    [[CWVideoFileCache sharedCache] purgeCache];
    [AOFetchUtilities markAllMessagesAsDeviceDeletedForUser:[[CWUserManager sharedInstance] localUserID]];
}

- (BOOL)hasNecessaryDiskSpace {
    
    if ([[CWVideoFileCache sharedCache] hasMinimumFreeDiskSpace]) {
        return YES;
    }
    else {
        [self clearDiskSpace];
        
        return [[CWVideoFileCache sharedCache] hasMinimumFreeDiskSpace];
    }
}

@end