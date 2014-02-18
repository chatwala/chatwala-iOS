//
//  CWMessageManager.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageManager.h"
#import "AppDelegate.h"
#import "CWMessageCell.h"
#import "CWUserManager.h"
#import "CWUtility.h"
#import "CWDataManager.h"
#import "CWServerAPI.h"
#import "CWPushNotificationsAPI.h"
#import "CWMessagesDownloader.h"

@interface CWMessageManager ()

@property (nonatomic,assign) BOOL needsOriginalMessageUploadURL;
@property (nonatomic,strong) NSString *tempUploadURLString;
@property (nonatomic,strong) NSString *tempMessageID;
@property (nonatomic,strong) NSString *tempDownloadURLString;
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
    return @"https://chatwala-qa-13.azurewebsites.net";
#elif USE_DEV_SERVER
    return @"https://chatwala-deveast-13.azurewebsites.net";
#elif USE_SANDBOX_SERVER
    return @"https://chatwala-sandbox-13.azurewebsites.net";
#elif USE_STAGING_SERVER
    return @"https://chatwala-prodeast-13.azurewebsites.net";
#else
    return @"https://chatwala-prodeast-13.azurewebsites.net";
#endif
    
}

- (NSString *)registerEndPoint {
    return [[self baseEndPoint]stringByAppendingPathComponent:@"register"];
}


- (NSString *)messagesEndPoint {
    return [[self baseEndPoint]stringByAppendingPathComponent:@"messages"];
}

- (NSString *)getUserMessagesEndPoint {
    return [[self baseEndPoint]stringByAppendingString:@"/users/%@/messages"];
}

- (NSString *)getMessageEndPoint {
    return [[self baseEndPoint]stringByAppendingString:@"/messages/%@"];
}

- (NSString *)putUserProfileEndPoint {
    return [[self baseEndPoint]stringByAppendingString:@"/users/%@/picture"];
}

- (NSURL *)messageCacheURL {
    NSString * const messagesCacheFile = @"messages";
    return [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:messagesCacheFile];
}

- (void)getMessagesForUser:(User *)user withCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock {
    NSString *user_id = user.userID;
    
    if (![user_id length]) {
        return;
    }
    else {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];

        NSString * url = [NSString stringWithFormat:[self getUserMessagesEndPoint],user_id] ;
        NSLog(@"fetching messages: %@", url);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *messages = [responseObject objectForKey:@"messages"];
            if([messages isKindOfClass:[NSArray class]]){

                CWMessagesDownloader *downloader = [[CWMessagesDownloader alloc] init];
                downloader.messageIdsForDownload = [self messageIDsFromResponse:messages];
                [downloader startWithCompletionBlock:^(NSArray *messagesDownloaded) {
                    
                    // Finished download, now update badge & send local push notification if necessary
                    if (completionBlock) {
                        
                        NSLog(@"Messags downloader completed fetches.");
                        
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
                    
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[CWUserManager sharedInstance] localUser] numberOfUnreadMessages]];
                }];
            }
            else {
                NSError * error = [NSError errorWithDomain:@"com.chatwala" code:6000 userInfo:@{@"reason":@"missing messages", @"response":responseObject}];
                self.getMessagesFailureBlock(operation, error);
                
                if (completionBlock) {
                    completionBlock(UIBackgroundFetchResultNoData);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            self.getMessagesFailureBlock(operation, error);
            
            if (completionBlock) {
                completionBlock(UIBackgroundFetchResultNoData);
            }
        }];
    }
}

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
        NSLog(@"operation:%@",operation);
        
        //            [SVProgressHUD showErrorWithStatus:@"failed to fecth messages"];
        [NC postNotificationName:@"MessagesLoadFailed" object:nil userInfo:nil];
        
    });
}

#pragma mark - table view datasource delegate functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    messageTable = tableView;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CWMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    User * localUser = [[CWUserManager sharedInstance] localUser];
    NSOrderedSet * inboxMessages = [localUser inboxMessages];
    Message * message = [inboxMessages objectAtIndex:indexPath.row];
    [cell setMessage:message];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    User * localUser = [[CWUserManager sharedInstance] localUser];
    NSOrderedSet * inboxMessages = [localUser inboxMessages];
    return inboxMessages.count;
}

#pragma mark - MessageID Server Fetches
//, [NSString stringWithFormat:@"http://chatwala.com/?%@",message.messageID]
- (void)fetchUploadURLForReplyToMessage:(Message *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock
 {
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSDictionary *params = @{@"sender_id" : message.sender.userID,
                             @"recipient_id" : message.recipient.userID};
     
    NSLog(@"Requesting reply message upload URL with params: %@", params);
    
    NSString *newMessageID = [self generateMessageID];
    NSString *endPoint = [NSString stringWithFormat:@"%@/%@", self.messagesEndPoint, newMessageID];
     
    [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *sasUploadUrl = [responseObject valueForKey:@"sasUrl"];
        
        NSLog(@"Fetched new message upload URL: %@ for messageID: %@", sasUploadUrl, newMessageID);
        if (completionBlock) {
            completionBlock(newMessageID, sasUploadUrl, [responseObject valueForKey:@"url"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Cannot deliver message."];
        
        NSLog(@"Failed to fetch SAS upload URL from server for reply messageID: %@ with error:%@", message.messageID, error);
        NSLog(@"operation:%@",operation);
        
        if (completionBlock) {
            completionBlock(nil, nil, nil);
        }
    }];
}

- (void)fetchUploadURLForOriginalMessage:(User *)localUser completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock {
    
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");

    // Check if we already have unused messageID we fetched earlier - return that
    if (!self.needsOriginalMessageUploadURL && [self.tempUploadURLString length] && [self.tempMessageID length] && self.tempDownloadURLString) {
        if (completionBlock) {
            completionBlock(self.tempMessageID, self.tempUploadURLString, self.tempDownloadURLString);
        }
        
        return;
    }
    
    // Cancel & cleanup previous requests
    [self.messageIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.messageIDOperation cancel];
    
    self.tempUploadURLString = nil;
    self.tempMessageID = nil;
    self.tempDownloadURLString = nil;
    self.messageIDOperation = nil;
    
    
    NSDictionary *params = @{@"sender_id" : localUser.userID,
                             @"recipient_id" : @"unknown_recipient"};
    
    NSLog(@"Requesting original message upload URL with params: %@", params);
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *newMessageID = [self generateMessageID];
    NSString *endPoint = [NSString stringWithFormat:@"%@/%@", self.messagesEndPoint, newMessageID];
    
    self.messageIDOperation = [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.needsOriginalMessageUploadURL = NO;
        self.tempUploadURLString = [responseObject valueForKey:@"sasUrl"];
        self.tempDownloadURLString = [responseObject valueForKey:@"url"];
        self.tempMessageID = newMessageID;
        
        NSLog(@"Fetched original message upload URL: %@: for new original message ID: %@",self.tempUploadURLString, self.tempMessageID);
        
        if (completionBlock) {
            completionBlock(self.tempMessageID, self.tempUploadURLString, self.tempDownloadURLString);
        }
        
        self.messageIDOperation = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.needsOriginalMessageUploadURL = YES;

        [SVProgressHUD showErrorWithStatus:@"Cannot deliver message."];
        
        NSLog(@"Failed to fetch original message upload ID from the server for a reply with error: %@",error);
        NSLog(@"operation: %@",operation);
        
        if (completionBlock) {
            completionBlock(nil,nil,nil);
        }
        
        self.messageIDOperation = nil;
    }];
}

- (void)clearUploadURLForOriginalMessage {

    // Cancel & cleanup previous requests
    [self.messageIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.messageIDOperation cancel];
    
    self.tempUploadURLString = nil;
    self.tempMessageID = nil;
    self.tempDownloadURLString = nil;
    self.messageIDOperation = nil;
    
    self.needsOriginalMessageUploadURL = YES;
}

- (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString isReply:(BOOL)isReplyMessage {

    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
    
    NSString * endPoint = uploadURLString;
    NSLog(@"uploading message: %@",endPoint);
    
    [CWServerAPI uploadMessage:messageToUpload toURL:endPoint withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error during message upload: %@", error);
        }
        else {
            NSLog(@"Successful message upload - messageID: %@", messageToUpload.messageID);
            
            // Call finalize
            [CWServerAPI finalizeMessage:messageToUpload];
        }
    }];
    
    // After this we'll need a different endpoint for upload if we cancel or kill the app
    
    if (!isReplyMessage) {
        self.needsOriginalMessageUploadURL = YES;
    }
}

#pragma mark - Helpers

- (NSString *)generateMessageID {
    return [[NSUUID UUID] UUIDString];
}

@end
