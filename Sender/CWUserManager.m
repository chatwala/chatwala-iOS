//
//  CWUserManager.m
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWUserManager.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"
#import "CWUtility.h"
#import "CWServerAPI.h"
#import "CWGroundControlManager.h"
#import "CWUserDefaultsController.h"


NSString * const kAppVersionOfFeedbackRequestedKey  = @"APP_VERSION_WHEN_FEEDBACK_REQUESTED";
NSString * const kNewMessageDeliveryMethodKey = @"kNewMessageDeliveryMethodKey";
NSString * const kNewMessageDeliveryMethodValueSMS = @"SMS";
NSString * const kNewMessageDeliveryMethodValueEmail = @"email";

NSString * const kUploadedProfilePictureKey = @"profilePictureKey";
NSString * const kApprovedProfilePictureKey = @"profilePictureApprovedKey";


@interface CWUserManager()


@end

@implementation CWUserManager

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {

    self = [super init];
    if (self) {
        [self setupHttpHeaders];

        if (!self.localUserID) {
            [self createNewLocalUser];
        }
    }
    return self;
}

- (void)setupHttpHeaders {
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", CWConstantsChatwalaAPIKey, CWConstantsChatwalaAPISecret];

    self.requestHeaderSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestHeaderSerializer setValue:keyAndSecret forHTTPHeaderField:CWConstantsChatwalaAPIKeySecretHeaderField];
    [self.requestHeaderSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:CWConstantsChatwalaVersionHeaderField];
}

- (void)addRequestHeadersToURLRequest:(NSMutableURLRequest *) request {

    NSDictionary * headerDictionary = [self.requestHeaderSerializer HTTPRequestHeaders];
    for (NSString * key in headerDictionary) {
        NSAssert([key isKindOfClass:[NSString class]], @"expecting strings for the keys of the request header. found: %@", key);
        NSString* value = [headerDictionary objectForKey:key];
        NSAssert([value isKindOfClass:[NSString class]], @"expecting strings for the values of the request header. found: %@", value);
        
        [request addValue:value forHTTPHeaderField:key];
    }
}


- (NSString *)localUserID {
    return [CWUserDefaultsController userID];
}

- (void)createNewLocalUser {
    NSString *newUserID = nil;

#if defined(OVERRIDE_USER_ID) && defined(DEBUG)
    newUserID = OVERRIDE_USER_ID;
#endif
    
    if (![newUserID length]) {
        newUserID =[[[NSUUID UUID] UUIDString] lowercaseString];
    }
    
    NSLog(@"Generated new user id: %@", newUserID);
    
    //self.localUser = [[CWDataManager sharedInstance] createUserWithID:newUserID];
    [CWUserDefaultsController setUserID:newUserID];
}

- (BOOL) hasApprovedProfilePicture:(NSString *) user {
    
    BOOL approved = [[NSUserDefaults standardUserDefaults] boolForKey:kApprovedProfilePictureKey];
    return approved;
}

- (void) approveProfilePicture:(NSString *) user {
    
    if (!user) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kApprovedProfilePictureKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) hasUploadedProfilePicture:(NSString *)userID {

    if([[[NSUserDefaults standardUserDefaults] objectForKey:kUploadedProfilePictureKey] boolValue]) {
        return YES;
    }
    
    return NO;
}

- (NSString *) getProfilePictureEndPointForUser:(NSString *)userID {
    //NSString * user_id = user.userID;
    
    //NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] putUserProfileEndPoint] , user_id];
    return nil;
}


- (void)uploadProfilePicture:(UIImage *)thumbnail forUser:(NSString *)userID completion:(void (^)(NSError * error))completionBlock {
    
    if (![userID length]) {
        return;
    }
    
    [CWServerAPI uploadProfilePicture:thumbnail forUserID:userID withCompletionBlock:^(NSError *error) {

        if (error) {
            NSLog(@"Error: %@", error);
            
            if (completionBlock) {
                completionBlock(error);
            }
        } else {

            NSLog(@"Successfully uploaded profile picture for user: %@", userID);
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUploadedProfilePictureKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (completionBlock) {
                completionBlock(nil);
            }
        }
    }];
}


- (BOOL) shouldRequestAppFeedback {

    if([self appVersionOfAppFeedbackRequest])
    {
        return NO;
    }
    NSInteger requestAppFeedbackThreshold = [[[CWGroundControlManager sharedInstance] appFeedbackSentMessageThreshold] integerValue];
    if([CWUserDefaultsController numberOfSentMessages] < requestAppFeedbackThreshold)
    {
        return NO;
    }
    
    return YES;
}

- (void) didRequestAppFeedback {
    
    NSString * buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:buildVersion forKey:kAppVersionOfFeedbackRequestedKey];
}


- (NSString*) appVersionOfAppFeedbackRequest
{
    NSString* appVersionWhenFeedbackRequested = [[NSUserDefaults standardUserDefaults] stringForKey:kAppVersionOfFeedbackRequestedKey];
    return appVersionWhenFeedbackRequested;
}

- (NSString *) newMessageDeliveryMethod
{
    NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:kNewMessageDeliveryMethodKey];
    return value ? value:kNewMessageDeliveryMethodValueSMS;
}

- (void) setNewMessageDeliveryMethod:(NSString *)newMessageDeliveryMethod
{
    [[NSUserDefaults standardUserDefaults] setObject:newMessageDeliveryMethod forKey:kNewMessageDeliveryMethodKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) newMessageDeliveryMethodIsSMS
{
    return [[self newMessageDeliveryMethod] isEqualToString:kNewMessageDeliveryMethodValueSMS];
}

- (NSInteger) numberOfTotalUnreadMessages {

    return [AOFetchUtilities totalUnreadMessagesForRecipient:self.localUserID];
}


+ (NSInteger)numberOfUnreadMessagesForRecipient:(NSString *)userID {
    NSArray *messagesForUser = [AOFetchUtilities fetchMessagesForSender:userID];
    NSInteger unreadCount = 0;
    
    for (Message *currentMessage in messagesForUser) {
        if (currentMessage.eMessageViewedState == eMessageViewedStateUnOpened && currentMessage.eDownloadState == eMessageDownloadStateDownloaded) {
            unreadCount++;
        }
    }
    
    return unreadCount;
}

@end

