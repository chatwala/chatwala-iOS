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

NSString *const pushRegisterEndpoint = @"/registerPushToken";

@implementation CWServerAPI

+ (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock {

    NSString * endPoint = uploadURLString;

    NSURL *URL = [NSURL URLWithString:endPoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];

    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:messageToUpload.zipURL.path error:nil] fileSize];

    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
    [request addValue:@"BlockBlob" forHTTPHeaderField:@"x-ms-blob-type"];
    [request addValue:[NSString stringWithFormat:@"%llu",fileSize] forHTTPHeaderField:@"content-length"];

    AFURLSessionManager *mgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *task = [mgr uploadTaskWithRequest:request fromFile:messageToUpload.zipURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] != 201) {
            
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            
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
    }];
    
    [task resume];
}

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
            NSLog(@"uploading profile image: %@",endPoint);
            
            NSURL *URL = [NSURL URLWithString:endPoint];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            [request setHTTPMethod:@"PUT"];
            [request addValue:@"BlockBlob" forHTTPHeaderField:@"x-ms-blob-type"];
            
            [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
            AFURLSessionManager * mgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            NSURLSessionUploadTask * task = [mgr uploadTaskWithRequest:request fromFile:thumbnailURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                
                NSHTTPURLResponse *pictureUploadResponse = (NSHTTPURLResponse *)response;
                if (pictureUploadResponse.statusCode != 201) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    
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
    
    
    NSString *endPoint = [NSString stringWithFormat:@"%@/users/%@/pictureUploadURL", [[CWMessageManager sharedInstance] baseEndPoint], userID];
    
    [manager GET:endPoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *pictureSasUrl = [responseObject objectForKey:@"sasUrl"];
        
        if ([pictureSasUrl length]) {
            NSLog(@"Fetched new profile picture upload ID.");
            
            if (completionBlock) {
                completionBlock(nil,[responseObject valueForKey:@"sasUrl"]);
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
        [SVProgressHUD showErrorWithStatus:@"Cannot deliver message."];
        
        NSLog(@"Failed to fetch picture upload ID from the server for a reply with error:%@",error);
        
        if (completionBlock) {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
            completionBlock(error, nil);
        }
    }];
    
}

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
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *endpoint = [[[CWMessageManager sharedInstance] baseEndPoint] stringByAppendingString:pushRegisterEndpoint];
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

+ (void)finalizeMessage:(Message *)uploadedMessage {
    
    NSString *recipientID = (uploadedMessage.recipient.userID ? uploadedMessage.recipient.userID : @"unknown_recipient");
    NSDictionary *params = @{@"sender_id" : uploadedMessage.sender.userID,
                 @"recipient_id" : recipientID};


    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    NSString *endPoint = [NSString stringWithFormat:@"%@/messages/%@/finalize", [[CWMessageManager sharedInstance] baseEndPoint], uploadedMessage.messageID];
    
    [requestManager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Successfully finalized message upload");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to finalize message upload. Error:  %@",error.localizedDescription);
    }];
}
@end
