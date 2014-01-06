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

- (id)init
{
    self = [super init];
    if (self) {
        useLocalServer = NO;
        self.needsOriginalMessageID = YES;
        [self loadCachedMessages];
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

- (void) loadCachedMessages
{
    self.messages = [NSArray arrayWithContentsOfURL:[self messageCacheURL]];
}

- (NSString *)baseEndPoint
{
    if (useLocalServer) {
        return @"http://192.168.0.102:1337";
    }
    
    
    NSInteger serverEnv = 0;
    //[[[NSUserDefaults standardUserDefaults] valueForKey:@"ServerEnvironment"]integerValue];
    if (serverEnv) {
        // development
        return @"http://chatwala-dev.azurewebsites.net";
    }else{
        // production
        return @"http://chatwala-prod.azurewebsites.net";
    }
}
#warning Need to update these names to better describe roles

- (NSString *)registerEndPoint
{
    return [[self baseEndPoint]stringByAppendingPathComponent:@"register"];
}


- (NSString *)messagesEndPoint
{
    return [[self baseEndPoint]stringByAppendingPathComponent:@"messages"];
}

- (NSString *)getUserMessagesEndPoint
{
    return [[self baseEndPoint]stringByAppendingString:@"/users/%@/messages"];
}

- (NSString *)getMessageEndPoint
{
    return [[self baseEndPoint]stringByAppendingString:@"/messages/%@"];
}

- (NSString *)putUserProfileEndPoint
{
    return [[self baseEndPoint]stringByAppendingString:@"/users/%@/picture"];
}


- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(BOOL success, NSURL *url))completionBlock
{
    // check if file exists locally
    NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[messageID stringByAppendingString:@".zip"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        // don't download
        NSURL * localURL =[NSURL fileURLWithPath:localPath];
        if (completionBlock) {
            completionBlock(YES,localURL);
        }
    }else{
        
        // do download
        NSString * messagePath =[NSString stringWithFormat:[self getMessageEndPoint],messageID];
        NSLog(@"downloading file at: %@",messagePath);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURL *URL = [NSURL URLWithString:messagePath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        NSProgress * progress;
        
        [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
        {
                                                                          
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
            return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
            
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if(error)
            {
                NSLog(@"error %@", error);
                if (completionBlock) {
                    completionBlock(NO,filePath);//if we need to pass error/response adjust function callback
                }
            }
            else
            {
                
                NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
                switch (httpResponse.statusCode) {
                    case 200:
                        // success
                        NSLog(@"File downloaded to: %@", filePath);
                        if (completionBlock) {
                            completionBlock(YES,filePath);
                        }
                        break;
                        
                    default:
                        // fail
                        NSLog(@"failed to load message file. with code:%i",httpResponse.statusCode);
                        if (completionBlock) {
                            completionBlock(NO,nil);
                        }
                        break;
                }
            }
        }];
        
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        [downloadTask resume];
    }
}

- (NSURL *) messageCacheURL
{
    NSString * const messagesCacheFile = @"messages";
    return [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:messagesCacheFile];
    
}

- (void)getMessagesWithCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock
{
    
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
    
    if([user_id length])
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
        
        NSString * url = [NSString stringWithFormat:[self getUserMessagesEndPoint],user_id] ;
        NSLog(@"fetching messages: %@",url);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            NSLog(@"fetched user messages: %@",responseObject);
            
            self.messages = [responseObject objectForKey:@"messages"];
            
            [self.messages writeToURL:[self messageCacheURL] atomically:YES];
            
            if (completionBlock) {
                
                // Only perform badge update when we are fetching due to a background fetch
                NSNumber *previousTotalMessages = [[NSUserDefaults standardUserDefaults] valueForKey:@"MESSAGE_INBOX_COUNT"];

                int newMessageCount = [self.messages count] - [previousTotalMessages intValue];
                if (newMessageCount > 0) {
                    int existingBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:existingBadgeNumber + newMessageCount];
                }
                
                completionBlock(UIBackgroundFetchResultNewData);
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.messages count]] forKey:@"MESSAGE_INBOX_COUNT"];
            [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            NSLog(@"failed to fetch messages with error: %@",error);
            NSLog(@"operation:%@",operation);

//            [SVProgressHUD showErrorWithStatus:@"failed to fecth messages"];
            [NC postNotificationName:@"MessagesLoadFailed" object:nil userInfo:nil];
            
            if (completionBlock) {
                completionBlock(UIBackgroundFetchResultNoData);
            }
        }];
    }
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
    NSDictionary * dict = [self.messages objectAtIndex:indexPath.row];
    [cell setMessageData:dict];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - MessageID Server Fetches

- (void)fetchMessageIDForReplyToMessage:(CWMessageItem *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock {
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    NSDictionary *params = @{@"sender_id" : message.metadata.senderId,
                             @"recipient_id" : message.metadata.recipientId};
    
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

- (void)fetchOriginalMessageIDWithCompletionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock {
    
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
    
    NSDictionary *params = @{@"sender_id" : [[CWUserManager sharedInstance] userId],
                             @"recipient_id" : @"unkown_recipient"};
    
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

- (void)uploadMesage:(CWMessageItem *)messageToUpload isReply:(BOOL)isReplyMessage {
    NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
    
    
    NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] getMessageEndPoint] ,messageToUpload.metadata.messageId];
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

- (void)completedDownload
{
//    [SVProgressHUD showSuccessWithStatus:@"message loaded"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSProgress *progress = (NSProgress *)object;
    CGFloat p = progress.fractionCompleted;
    if (p < 1.0) {
        [self performSelectorOnMainThread:@selector(updateProgressView:) withObject:@(p) waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(completedDownload) withObject:nil waitUntilDone:NO];
    }
}




@end
