//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "User.h"


typedef void (^CWUserManagerRegisterUserCompletionBlock)(NSError *error);

extern NSString * const kAppVersionOfFeedbackRequestedKey;
extern NSString * const kNewMessageDeliveryMethodValueSMS;
extern NSString * const kNewMessageDeliveryMethodValueEmail;

typedef void (^CWUserManagerLocalUserBlock)(User *localUser);
typedef void (^CWUserManagerGetUserIDFetchBlock)(AFHTTPRequestOperation *operation, id responseObject, CWUserManagerLocalUserBlock completion);


@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;
@property (nonatomic,readonly) User *localUser;
@property (nonatomic) NSString * newMessageDeliveryMethod;

- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;
//- (void)uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user;
- (void) uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user completion:(void (^)(NSError * error))completionBlock;

- (BOOL)hasApprovedProfilePicture:(User *) user;
- (void)approveProfilePicture:(User *) user;
- (BOOL)hasUploadedProfilePicture:(User *) user;

- (NSString *) getProfilePictureEndPointForUser:(User *) user;
- (NSString *)appVersionOfAppFeedbackRequest;
- (void) didRequestAppFeedback;
- (BOOL) shouldRequestAppFeedback;
- (BOOL) newMessageDeliveryMethodIsSMS;

@end
