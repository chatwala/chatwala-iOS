//
//  CWServerAPI.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/30/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

typedef void (^CWServerAPIUploadCompletionBlock)(NSError *error);
typedef void (^CWServerPushRegisterCompletionBlock)(NSError *error);

typedef NSURL * (^CWServerAPIDownloadDestinationBlock) (NSURL *targetPath, NSURLResponse *response);


@class Message;

@interface CWServerAPI : NSObject

+ (AFURLSessionManager *)sessionManager;

+ (void)uploadProfilePicture:(UIImage *)thumbnail forUserID:(NSString *)userID withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock;
+ (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock;

+ (void)registerPushForUserID:(NSString *)userID withPushToken:(NSString *)pushToken withCompletionBlock:(CWServerPushRegisterCompletionBlock)completionBlock;
+ (void)finalizeMessage:(Message *)uploadedMessage;

+ (void)downloadMessageForID:(NSString *)messageID destinationURLBlock:(CWServerAPIDownloadDestinationBlock)destinationBlock completionBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock;


@end
