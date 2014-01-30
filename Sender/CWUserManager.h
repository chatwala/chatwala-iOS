//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

extern NSString * const kAppVersionOfFeedbackRequestedKey;
extern NSString * const kNewMessageDeliveryMethodValueSMS;
extern NSString * const kNewMessageDeliveryMethodValueEmail;

typedef void (^CWUserManagerLocalUserBlock)(User *localUser);
typedef void (^CWUserManagerGetUserIDFetchBlock)(AFHTTPRequestOperation *operation, id responseObject, CWUserManagerLocalUserBlock completion);

@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;


- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;

@property (nonatomic, readonly) User * localUser __attribute__((deprecated("use localUser:")));

@property (nonatomic) NSString * newMessageDeliveryMethod;

- (BOOL) hasLocalUser;
- (void) localUser:(void (^)(User *localUser)) completion;

- (BOOL) hasApprovedProfilePicture:(User *) user;
- (void) approveProfilePicture:(User *) user;
- (void) uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user completion:(void (^)(User * user, NSError * error))completion;
- (BOOL) hasUploadedProfilePicture:(User *) user;
- (NSString *) getProfilePictureEndPointForUser:(User *) user;
- (NSString *)appVersionOfAppFeedbackRequest;
- (void) didRequestAppFeedback;
- (BOOL) shouldRequestAppFeedback;
- (BOOL) newMessageDeliveryMethodIsSMS;


#pragma mark - blocks for fetch results

@property (strong, readonly) CWUserManagerGetUserIDFetchBlock getUserIDCompletionBlock;

@end
