//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "User.h"

typedef void (^CWUserManagerRegisterUserCompletionBlock)(NSError *error);

@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;
@property (nonatomic,readonly) User *localUser;

- (void)addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;

- (void)registerUserWithCompletionBlock:(CWUserManagerRegisterUserCompletionBlock)completionBlock;
- (void)registerUserWithPushToken:(NSString *)pushToken withCompletionBlock:(CWUserManagerRegisterUserCompletionBlock)completionBlock;

- (void)uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user;
- (BOOL)hasProfilePicture:(User *) user;
- (NSString *) getProfilePictureEndPointForUser:(User *) user;

@end
