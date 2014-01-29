//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

extern NSString * const kAppVersionWhenFeedbackRequestedKey;

typedef void (^CWUserManagerLocalUserBlock)(User *localUser);
typedef void (^CWUserManagerGetUserIDFetchBlock)(AFHTTPRequestOperation *operation, id responseObject, CWUserManagerLocalUserBlock completion);

@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;


- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;

@property (nonatomic, readonly) User * localUser __attribute__((deprecated("use localUser:")));

- (BOOL) hasLocalUser;
- (void) localUser:(void (^)(User *localUser)) completion;

- (void) uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user;
- (BOOL) hasProfilePicture:(User *) user;
- (NSString *) getProfilePictureEndPointForUser:(User *) user;
- (NSString *)appFeedbackHasBeenRequested;
- (void) didRequestAppFeedback;
- (BOOL) shouldRequestAppFeedback;

#pragma mark - blocks for fetch results

@property (strong, readonly) CWUserManagerGetUserIDFetchBlock getUserIDCompletionBlock;

@end
