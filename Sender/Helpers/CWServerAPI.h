//
//  CWServerAPI.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/30/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

typedef void (^CWServerAPIUploadCompletionBlock)(NSError *error);
typedef void (^CWServerPushRegisterCompletionBlock)(NSError *error);

typedef void (^CWServerGetProfilePictureURLCompletionBlock)(NSURL *profilePictureReadURL);

typedef void (^CWServerAPIGetInboxCompletionBlock)(NSArray *messages, NSError *error);
typedef void (^CWServerAPIDownloadProgressBlock) (float fractionCompleted);
typedef NSURL * (^CWServerAPIDownloadDestinationBlock) (NSURL *targetPath, NSURLResponse *response);

@class Message;

@interface CWServerAPI : NSObject

+ (AFURLSessionManager *)sessionManager;

// Inbox API
+ (void)getInboxForUserID:(NSString *)userID withCompletionBlock:(CWServerAPIGetInboxCompletionBlock)completionBlock;
+ (void)addMessage:(NSString *)messageID toInboxForUser:(NSString *)userID;

// Message Upload API
+ (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock;
+ (void)completeMessage:(Message *)uploadedMessage isReply:(BOOL)isReply;

// Picture Upload API
+ (void)getProfilePictureReadURLForUser:(NSString *)userID withCompletionBlock:(CWServerGetProfilePictureURLCompletionBlock)completionBlock;
+ (void)uploadProfilePicture:(UIImage *)thumbnail forUserID:(NSString *)userID withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock;

// Push notifications API
+ (void)registerPushForUserID:(NSString *)userID withPushToken:(NSString *)pushToken withCompletionBlock:(CWServerPushRegisterCompletionBlock)completionBlock;

// Download API
+ (void)downloadMessageFromReadURL:(NSString *)endPoint destinationURLBlock:(CWServerAPIDownloadDestinationBlock)destinationBlock progressOrNil:(CWServerAPIDownloadProgressBlock)progressBlock completionBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock;

@end