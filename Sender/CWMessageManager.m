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

@interface CWMessageManager ()

@property (nonatomic,assign) BOOL needsMessageUploadURL;
@property (nonatomic,strong) NSString *tempUploadURLString;
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
        self.needsMessageUploadURL = YES;
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
    
    if (![user_id length]) {
        return;
    }
    else {
        
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
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[CWUserManager sharedInstance] localUser] numberOfUnreadMessages]];
            [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
        }
        else{
            NSError * error = [NSError errorWithDomain:@"com.chatwala" code:6000 userInfo:@{@"reason":@"missing messages", @"response":responseObject}];
            self.getMessagesFailureBlock(operation, error);
        }
    });
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

- (void)fetchUploadURLForReplyToMessage:(Message *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock
 {
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSDictionary *params = @{@"sender_id" : message.sender.userID,
                             @"recipient_id" : message.recipient.userID};
    
    NSString *endPoint = [NSString stringWithFormat:@"%@/%@", self.messagesEndPoint, message.messageID];
     
    [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Fetched new message upload ID: %@: and URL: %@",self.tempUploadURLString, self.originalMessageURL);
        
        if (completionBlock) {
            completionBlock([responseObject valueForKey:@"sasUrl"], [NSString stringWithFormat:@"http://chatwala.com/?%@",message.messageID]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Cannot deliver message."];
        
        NSLog(@"Failed to fetch SAS upload URL from server for reply messageID: %@ with error:%@", message.messageID, error);
        NSLog(@"operation:%@",operation);
        
        if (completionBlock) {
            completionBlock(nil, nil);
        }
    }];
}

- (void)fetchUploadURLForOriginalMessage:(User *)localUser messageID:(NSString *)messageID completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock {
    
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");

    // Check if we already have unused messageID we fetched earlier - return that
    if (!self.needsMessageUploadURL && [self.tempUploadURLString length] && [self.originalMessageURL length]) {
        if (completionBlock) {
            completionBlock(self.tempUploadURLString, self.originalMessageURL);
        }
        
        return;
    }
    
    // Cancel & cleanup previous requests
    [self.messageIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.messageIDOperation cancel];
    
    self.tempUploadURLString = nil;
    self.originalMessageURL = nil;
    self.messageIDOperation = nil;
    
    
    NSDictionary *params = @{@"sender_id" : localUser.userID,
                             @"recipient_id" : @"unknown_recipient"};
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *endPoint = [NSString stringWithFormat:@"%@/%@", self.messagesEndPoint, messageID];
    
    self.messageIDOperation = [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.needsMessageUploadURL = NO;
        self.tempUploadURLString = [responseObject valueForKey:@"sasUrl"];
        self.originalMessageURL = [NSString stringWithFormat:@"http://chatwala.com/?%@",messageID];
        
        NSLog(@"Fetched new message upload ID: %@: and URL: %@",self.tempUploadURLString, self.originalMessageURL);
        
        if (completionBlock) {
            completionBlock(self.tempUploadURLString, self.originalMessageURL);
        }
        
        self.messageIDOperation = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.needsMessageUploadURL = YES;
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

- (void)fetchUploadDetailsWithCompletionBlock:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock {

    // POST to /messagse/:id:/getUploadURL
    // expects a SAS URL which can be used to upload
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
        self.needsMessageUploadURL = YES;
    }
}
@end
