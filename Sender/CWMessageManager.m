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


@interface CWMessageManager ()

@property (nonatomic,assign) BOOL needsOriginalMessageID;
@property (nonatomic,strong) NSString *originalMessageID;
@property (nonatomic,strong) NSString *originalMessageURL;
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
        self.needsOriginalMessageID = YES;
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
    return @"http://chatwala-deveast.azurewebsites.net";
#elif USE_DEV_SERVER
    return @"http://chatwala-deveast.azurewebsites.net";
#elif USE_SANDBOX_SERVER
    return @"http://chatwala-sandbox.azurewebsites.net";
#else
    return @"http://chatwala-prodeast.azurewebsites.net";
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

- (AFDownloadTaskDestinationBlock) downloadURLDestinationBlock {
    
    return (^NSURL *(NSURL *targetPath, NSURLResponse *response){
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    });
}

- (CWDownloadTaskCompletionBlock) downloadTaskCompletionBlock {
    
    return (^ void(NSURLResponse *response, NSURL *filePath, NSError *error, CWMessageDownloadCompletionBlock  messageDownloadCompletionBlock){
        
        if(error) {
            NSLog(@"error %@", error);
            if (messageDownloadCompletionBlock) {
                messageDownloadCompletionBlock(NO,filePath);//if we need to pass error/response adjust function callback
            }
        }
        else {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: {
                    // success
                    NSLog(@"File downloaded to: %@", filePath);
                    NSError * error = nil;
                    [[CWDataManager sharedInstance] importMessageAtFilePath:filePath withError:&error];
                    NSAssert(!error, @"not expecting an error, found:%@",error);
                    if (messageDownloadCompletionBlock) {
                        messageDownloadCompletionBlock(YES,filePath);
                    }
                    
                    break;
                }
                default:
                    // fail
                    NSLog(@"failed to load message file. with code:%i",httpResponse.statusCode);
                    if (messageDownloadCompletionBlock) {
                        messageDownloadCompletionBlock(NO,nil);
                    }
                    break;
            }
        }
    });
}

- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(CWMessageDownloadCompletionBlock )completionBlock
{
    // check if file exists locally
    NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[messageID stringByAppendingString:@".zip"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        // don't download
        NSURL * localURL =[NSURL fileURLWithPath:localPath];
        if (completionBlock) {
            completionBlock(YES,localURL);
        }
    }
    else {
        
        // do download
        NSString * messagePath =[NSString stringWithFormat:[self getMessageEndPoint],messageID];
        NSLog(@"downloading file at: %@",messagePath);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURL *URL = [NSURL URLWithString:messagePath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:self.downloadURLDestinationBlock completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            self.downloadTaskCompletionBlock(response,filePath,error,completionBlock);
        }];
        

        [downloadTask resume];
    }
}

- (NSURL *)messageCacheURL {
    NSString * const messagesCacheFile = @"messages";
    return [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:messagesCacheFile];
}

- (void)getMessagesForUser:(User *) user withCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock {
    NSString *user_id = user.userID;
    
    if([user_id length]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];

        NSString * url = [NSString stringWithFormat:[self getUserMessagesEndPoint],user_id] ;
        NSLog(@"fetching messages: %@",url);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            self.getMessagesSuccessBlock(operation, responseObject);
            
            if (completionBlock) {
                completionBlock(UIBackgroundFetchResultNewData);
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

- (AFRequestOperationManagerSuccessBlock) getMessagesSuccessBlock {
    
    return (^ void(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"fetched user messages: %@",responseObject);
        
        NSArray *messages = [responseObject objectForKey:@"messages"];
        if([messages isKindOfClass:[NSArray class]]){
            
            [[CWDataManager sharedInstance] importMessages:messages];
            
            [[CWUserManager sharedInstance] localUser:^(User *localUser) {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[localUser numberOfUnreadMessages]];
            }];
            [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
        }
        else{
            NSError * error = [NSError errorWithDomain:@"com.chatwala" code:6000 userInfo:@{@"reason":@"missing messages", @"response":responseObject}];
            self.getMessagesFailureBlock(operation, error);
        }

    });
}

- (AFRequestOperationManagerFailureBlock) getMessagesFailureBlock
{
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

- (void) fetchMessageIDForReplyToMessage:(Message *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock
{
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSDictionary *params = @{@"sender_id" : message.sender.userID,
                             @"recipient_id" : message.recipient.userID};
    
    [manager POST:self.messagesEndPoint parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // Nothing needed here
        // Should we change this to not use multipart then?
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Fetched new message upload ID: %@: and URL: %@",self.originalMessageID, self.originalMessageURL);
        
        if (completionBlock) {
            completionBlock([responseObject valueForKey:@"message_id"], [responseObject valueForKey:@"url"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"Cannot deliver message."];
        
        NSLog(@"Failed to fetch message ID from the server for a reply with error:%@",error);
        NSLog(@"operation:%@",operation);
        
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    }];
    
}

- (void)fetchOriginalMessageIDWithSender:(User *) localUser completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock {
    
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");

    // Check if we already have unused messageID we fetched earlier - return that
    if (!self.needsOriginalMessageID && [self.originalMessageID length] && [self.originalMessageURL length]) {
        if (completionBlock) {
            completionBlock(self.originalMessageID, self.originalMessageURL);
        }
        
        return;
    }
    
    // Cancel & cleanup previous requests
    [self.messageIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.messageIDOperation cancel];
    
    self.originalMessageID = nil;
    self.originalMessageURL = nil;
    self.messageIDOperation = nil;
    
    
    NSDictionary *params = @{@"sender_id" : localUser.userID,
                             @"recipient_id" : @"unknown_recipient"};
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    self.messageIDOperation = [manager POST:self.messagesEndPoint parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // Nothing needed here
        // Should we change this to not use multipart then?
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        self.needsOriginalMessageID = NO;
        self.originalMessageID = [responseObject valueForKey:@"message_id"];
        self.originalMessageURL = [responseObject valueForKey:@"url"];
        
        NSLog(@"Fetched new message upload ID: %@: and URL: %@",self.originalMessageID, self.originalMessageURL);
        
        if (completionBlock) {
            completionBlock(self.originalMessageID, self.originalMessageURL);
        }
        
        self.messageIDOperation = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.needsOriginalMessageID = YES;
        NSLog(@"Error retrieving message ID or URL from the server");
        [SVProgressHUD showErrorWithStatus:@"Cannot deliver message."];
        
        NSLog(@"Failed to fetched new message upload ID from the server for a reply with error:%@",error);
        NSLog(@"operation:%@",operation);
        
        if (completionBlock) {
            completionBlock(nil,nil);
        }
        
        self.messageIDOperation = nil;
    }];

}

- (void)uploadMessage:(Message *) messageToUpload isReply:(BOOL)isReplyMessage
{
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
    
    
    NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] getMessageEndPoint] ,messageToUpload.messageID];
    NSLog(@"uploading message: %@",endPoint);
    NSURL *URL = [NSURL URLWithString:endPoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];

    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
    
    AFURLSessionManager *mgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionUploadTask *task = [mgr uploadTaskWithRequest:request fromFile:messageToUpload.zipURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            NSLog(@"Error during message upload: %@", error);
            NSLog(@"Response : %@", response);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            NSLog(@"Successful message upload: %@ %@", response, responseObject);
        }
    }];
    
    // After this we'll need a different endpoint for upload if we cancel or kill the app
    
    if (!isReplyMessage) {
        self.needsOriginalMessageID = YES;
    }
    
    
    [task resume];
}

- (void)updateProgressView:(NSNumber*)p
{
//    [SVProgressHUD showProgress:p.floatValue status:@"loading message"];
    CWMessageCell *cell = (CWMessageCell *)[messageTable cellForRowAtIndexPath:selectedIndexPath];
    [cell setProgress:p.floatValue];
}

@end
