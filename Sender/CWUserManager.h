//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


typedef void (^CWUserManagerRegisterUserCompletionBlock)(NSError *error);

extern NSString * const kAppVersionOfFeedbackRequestedKey;
extern NSString * const kNewMessageDeliveryMethodValueSMS;
extern NSString * const kNewMessageDeliveryMethodValueEmail;

//typedef void (^CWUserManagerLocalUserBlock)(User *localUser);
//typedef void (^CWUserManagerGetUserIDFetchBlock)(AFHTTPRequestOperation *operation, id responseObject, CWUserManagerLocalUserBlock completion);


@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;
@property (nonatomic,readonly) NSString *localUserID;
@property (nonatomic) NSString * newMessageDeliveryMethod;

- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;
//- (void)uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user;
- (void)uploadProfilePicture:(UIImage *)thumbnail forUser:(NSString *)userID completion:(void (^)(NSError * error))completionBlock;

- (BOOL)hasApprovedProfilePicture:(NSString *)userID;
- (void)approveProfilePicture:(NSString *)userID;
- (BOOL)hasUploadedProfilePicture:(NSString *)userID;

- (NSString *) getProfilePictureEndPointForUser:(NSString *)userID;
- (NSString *)appVersionOfAppFeedbackRequest;
- (void) didRequestAppFeedback;
- (BOOL) shouldRequestAppFeedback;
- (BOOL) newMessageDeliveryMethodIsSMS;

- (NSInteger)numberOfUnreadMessages;
- (NSInteger)numberOfSentMessages;
+ (NSInteger)numberOfUnreadMessagesForUser:(NSString *)userID;

@end
