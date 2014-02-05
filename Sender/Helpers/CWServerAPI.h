//
//  CWServerAPI.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/30/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

typedef void (^CWServerAPIUploadCompletionBlock)(NSError *error);
typedef void (^CWServerPushRegisterCompletionBlock)(NSError *error);

@class Message;

@interface CWServerAPI : NSObject

+ (void)uploadProfilePicture:(UIImage *)thumbnail forUserID:(NSString *)userID withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock;
+ (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString withCompletionBlock:(CWServerAPIUploadCompletionBlock)completionBlock;

+ (void)registerPushForUserID:(NSString *)userID withPushToken:(NSString *)pushToken withCompletionBlock:(CWServerPushRegisterCompletionBlock)completionBlock;
+ (void)finalizeMessage:(Message *)uploadedMessage;

@end
