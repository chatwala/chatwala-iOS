//
//  CWServerAPI.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/30/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWServerAPI.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"
#import "CWUtility.h"
#import "CWUserManager.h"

typedef void (^CWPictureUploadEndpointRequestCompletionBlock)(NSError *error, NSString *tempUploadUrl);

UIBackgroundTaskIdentifier UploadBackgroundTaskIdentifier;
UIBackgroundTaskIdentifier CompleteSendBackgroundTaskIdentifier;

NSString *const PushRegisterEndpoint = @"/user/registerPushToken";
NSString *const GetMessageReadURLEndpoint = @"/messages/postGetReadURLForMessage";
NSString *const GetProfilePictureSASEndpoint = @"/user/postUserProfilePicture";
NSString *const AddMessageToInboxEndpoint = @"/messages/addUnknownRecipientMessageToInbox";
NSString *const CompleteOriginalMessageEndpoint = @"/messages/completeUnknownRecipientMessageSend";
NSString *const CompleteReplyMessageEndpoint = @"/messages/completeReplyMessageSend";

#ifdef USE_QA_SERVER
NSString *const BackgroundSessionIdentifier = @"com.chatwala.qa.backgroundSession";
#elif USE_DEV_SERVER
NSString *const BackgroundSessionIdentifier = @"com.chatwala.dev.backgroundSession";
#elif USE_SANDBOX_SERVER
NSString *const BackgroundSessionIdentifier = @"com.chatwala.dev.backgroundSession";
#else
NSString *const BackgroundSessionIdentifier = @"com.chatwala.chatwala.backgroundSession";
#endif

AFURLSessionManager *BackgroundSessionManager;

@implementation CWServerAPI

#pragma mark - Upload API methods

+ (AFURLSessionManager *)sessionManager {
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        return [self backgroundSessionManager];
    }
    else {
        NSURLSessionConfiguration *foregroundSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        foregroundSessionConfiguration.URLCache = nil;
        return [[AFURLSessionManager alloc] initWithSessionConfiguration:foregroundSessionConfiguration];
    }
}

+ (AFURLSessionManager *)backgroundSessionManager {

    static AFURLSessionManager *BackgroundSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:BackgroundSessionIdentifier];
        sessionConfig.URLCache = nil;
        BackgroundSessionManager = [[AFURLSessionManager alloc]initWithSessionConfiguration:sessionConfig];
    });
    
    return BackgroundSessionManager;
}

#pragma mark - Inbox API

+ (void)getInboxForUserID:(NSString *)userID withCompletionBlock:(CWServerAPIGetInboxCompletionBlock)completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *endpoint = [[CWMessageManager sharedInstance] getInboxEndPoint];
    NSLog(@"fetching messages: %@", endpoint);
    
    NSDictionary *params = @{@"user_id" : userID};
    
    [manager POST:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *messages = [responseObject objectForKey:@"messages"];
        
        if (completionBlock) {
            completionBlock(messages, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

+ (void)addMessage:(NSString *)messageID toInboxForUser:(NSString *)userID {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *endpoint = [[[CWMessageManager sharedInstance] baseEndPoint] stringByAppendingString:@"/messages/addUnknownRecipientMessageToInbox"];
    NSDictionary *params = @{@"message_id" : messageID,
                             @"recipient_id" : userID};
    
    [manager POST:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Successfully added message: %@ to inbox", messageID);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Unable to add message: %@ to inbox", messageID);
    }];

}

#pragma mark - Message Upload API

+ (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock {

    NSString * endPoint = uploadURLString;

    NSURL *URL = [NSURL URLWithString:endPoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];

    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:messageToUpload.zipURL.path error:nil] fileSize];

    NSLog(@"Starting message upload to sasURL: %@", endPoint);

    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
    [request addValue:@"BlockBlob" forHTTPHeaderField:@"x-ms-blob-type"];
    [request addValue:[NSString stringWithFormat:@"%llu",fileSize] forHTTPHeaderField:@"content-length"];

    AFURLSessionManager *mgr = [self sessionManager];
    
    if (UploadBackgroundTaskIdentifier != 0) {
        [[UIApplication sharedApplication] endBackgroundTask:UploadBackgroundTaskIdentifier];
        UploadBackgroundTaskIdentifier = 0;
    }
    
    UploadBackgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        UploadBackgroundTaskIdentifier = 0;
    }];
    
    
    NSURLSessionUploadTask *task = [mgr uploadTaskWithRequest:request fromFile:messageToUpload.zipURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] != 201) {
            
            NSLog(@"Failed to upload message.");
            [SVProgressHUD showErrorWithStatus:@"Failed to upload message."];
            
            if (completionBlock) {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
                completionBlock(error);
            }
            
        } else {
            NSLog(@"Successful message upload: %@ %@", response, responseObject);
            if (completionBlock) {
                completionBlock(nil);
            }
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:UploadBackgroundTaskIdentifier];
        UploadBackgroundTaskIdentifier = 0;
    }];
    
    [task resume];
}

+ (void)completeMessage:(Message *)uploadedMessage isReply:(BOOL)isReply {
    
    NSDictionary *params = @{@"message_id" : uploadedMessage.messageID};
    
    NSLog(@"Requesting message Finalize with params: %@", params);
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    [requestManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:[CWServerAPI versionHeaderFieldString]];
    
    NSString *serverAction = (isReply ? CompleteReplyMessageEndpoint : CompleteOriginalMessageEndpoint);
    NSString *endPoint = [[[CWMessageManager sharedInstance] baseEndPoint] stringByAppendingString:serverAction];
    
    // Terminate existing background tasks if this call was made twice
    if (CompleteSendBackgroundTaskIdentifier != 0) {
        [[UIApplication sharedApplication] endBackgroundTask:CompleteSendBackgroundTaskIdentifier];
        CompleteSendBackgroundTaskIdentifier = 0;
    }
    
    // Ensure this request continues by creating a background task for it
    CompleteSendBackgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        CompleteSendBackgroundTaskIdentifier = 0;
    }];
    
    [requestManager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully completed message upload");
        [[UIApplication sharedApplication] endBackgroundTask:CompleteSendBackgroundTaskIdentifier];
        CompleteSendBackgroundTaskIdentifier = 0;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to complete message upload. Error:  %@",error.localizedDescription);
        [[UIApplication sharedApplication] endBackgroundTask:CompleteSendBackgroundTaskIdentifier];
        CompleteSendBackgroundTaskIdentifier = 0;
    }];
}

#pragma mark - Picture API

+ (void)uploadProfilePicture:(UIImage *)thumbnail forUserID:(NSString *)userID withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock {
    
    [CWServerAPI getPictureUploadURLForUser:userID withCompletionBlock:^(NSError *error, NSString *tempUploadUrl) {
        if (error || !tempUploadUrl) {
            // Failure
        }
        else {

            NSLog(@"thumbnail created:%@", thumbnail);
            
            NSURL * thumbnailURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"thumbnailImage.png"];
            [UIImageJPEGRepresentation(thumbnail, 1.0) writeToURL:thumbnailURL atomically:YES];
            
            NSString *endPoint = tempUploadUrl;
            NSLog(@"Starting profile picture upload to sasURL: %@", endPoint);
            
            NSURL *URL = [NSURL URLWithString:endPoint];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            [request setHTTPMethod:@"PUT"];
            [request addValue:@"BlockBlob" forHTTPHeaderField:@"x-ms-blob-type"];
            [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
            
            [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
            AFURLSessionManager * mgr = [self sessionManager];
            
            NSURLSessionUploadTask * task = [mgr uploadTaskWithRequest:request fromFile:thumbnailURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                
                NSHTTPURLResponse *pictureUploadResponse = (NSHTTPURLResponse *)response;
                if (pictureUploadResponse.statusCode != 201) {
                    NSLog(@"Error uploading profile picture: %@", error);
                    
                    if (completionBlock) {
                        completionBlock(error);
                    }
                } else {
                    NSLog(@"Successfully upload profile picture: %@ %@", response, responseObject);
                    
                    if (completionBlock) {
                        completionBlock(nil);
                    }
                }
            }];
            
            [task resume];
        }
    }];
}

+ (void)getPictureUploadURLForUser:(NSString *)userID withCompletionBlock:(CWPictureUploadEndpointRequestCompletionBlock)completionBlock {
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSDictionary *params = @{@"user_id" : userID};
    NSString *endPoint = [[[CWMessageManager sharedInstance] baseEndPoint] stringByAppendingString:GetProfilePictureSASEndpoint];
    
    NSLog(@"Requesting new profile picture upload url from:  %@", endPoint);
    
    [manager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *pictureSasUrl = [responseObject objectForKey:@"write_url"];
        
        if ([pictureSasUrl length]) {
            NSLog(@"Fetched new profile picture upload ID.");
            
            if (completionBlock) {
                completionBlock(nil,pictureSasUrl);
            }
        }
        else {

            NSLog(@"No picture upload URL received.");
            
            if (completionBlock) {
                // TODO: put real errors here
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
                completionBlock(error, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed to fetch picture upload ID from the server for a reply with error:%@",error);
        
        if (completionBlock) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
            completionBlock(error, nil);
        }
    }];
}

#pragma mark - Push Notification & finalization calls 

+ (void)registerPushForUserID:(NSString *)userID withPushToken:(NSString *)pushToken withCompletionBlock:(CWServerPushRegisterCompletionBlock)completionBlock {

    NSDictionary *params = nil;
    
    if (![pushToken length] || ![userID length]) {
        if (completionBlock) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
            completionBlock(error);
        }
        
        return;
    }
    else {
        params =   @{@"user_id" : userID,
                     @"push_token" : pushToken,
                     @"platform_type" : @"ios"};
    }

    NSLog(@"Requesting push notification registration with params: %@", params);
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    [requestManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:[CWServerAPI versionHeaderFieldString]];
    
    NSString *endpoint = [[[CWMessageManager sharedInstance] baseEndPoint] stringByAppendingString:PushRegisterEndpoint];
    [requestManager POST:endpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Successfully registered local user with chatwala server");
        
        if (completionBlock) {
            completionBlock(nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to register user. Error:  %@",error.localizedDescription);
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

#pragma mark - Download API

+ (void)downloadMessageFromReadURL:(NSString *)endPoint destinationURLBlock:(CWServerAPIDownloadDestinationBlock)destinationBlock completionBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock {

    NSLog(@"Successfully fetched message read url.");
    
    // do download
    NSString * messagePath = endPoint;
    NSLog(@"downloading file from: %@", messagePath);
    
    
    AFURLSessionManager *manager = [self sessionManager];
    NSURL *URL = [NSURL URLWithString:messagePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:destinationBlock completionHandler:completionBlock];
    [downloadTask resume];
}

+ (void)downloadMessageForID:(NSString *)downloadID destinationURLBlock:(CWServerAPIDownloadDestinationBlock)destinationBlock completionBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock {

    NSDictionary *params = @{@"share_url_id" : downloadID};
    NSLog(@"Requesting message read URL with params: %@", params);
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    [requestManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:[CWServerAPI versionHeaderFieldString]];
    
    
    NSString *endPoint = [[[CWMessageManager sharedInstance] baseEndPoint] stringByAppendingString:GetMessageReadURLEndpoint];
    
    // Let's request the read URL from which we can download our message file
    [requestManager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully fetched message read url.");
        
        // do download
        NSString * messagePath = [responseObject objectForKey:@"read_url"];
        NSLog(@"downloading file from: %@", messagePath);
        
        
        AFURLSessionManager *manager = [self sessionManager];
        NSURL *URL = [NSURL URLWithString:messagePath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
        [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:destinationBlock completionHandler:completionBlock];
        [downloadTask resume];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get message file read url. Error:  %@",error.localizedDescription);
        
        if (completionBlock) {
            completionBlock(operation.response,nil,error);
        }
    }];
}


# pragma mark - Convenience methods
+ (NSString *)versionHeaderFieldString {
    return @"x-chatwala-appversion";
}

@end
