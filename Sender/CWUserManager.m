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


NSString * const kChatwalaAPIKey = @"58041de0bc854d9eb514d2f22d50ad4c";
NSString * const kChatwalaAPISecret = @"ac168ea53c514cbab949a80bebe09a8a";
NSString * const kChatwalaAPIKeySecretHeaderField = @"x-chatwala";

NSString * const kAppVersionOfFeedbackRequestedKey  = @"APP_VERSION_WHEN_FEEDBACK_REQUESTED";
NSString * const kNewMessageDeliveryMethodKey = @"kNewMessageDeliveryMethodKey";
NSString * const kNewMessageDeliveryMethodValueSMS = @"SMS";
NSString * const kNewMessageDeliveryMethodValueEmail = @"email";

NSString * const kUploadedProfilePictureKey = @"profilePictureKey";
NSString * const kApprovedProfilePictureKey = @"profilePictureApprovedKey";


@interface CWUserManager()

@property (nonatomic) User *localUser;

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
        [self setupHttpAuthHeaders];

        if (!self.localUser) {
            [self createNewLocalUser];
        }
    }
    return self;
}

- (void)setupHttpAuthHeaders {
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", kChatwalaAPIKey, kChatwalaAPISecret];

    self.requestHeaderSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestHeaderSerializer setValue:keyAndSecret forHTTPHeaderField:kChatwalaAPIKeySecretHeaderField];
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


- (User *)localUser {
    
    NSString *existingUserId = [CWUserDefaultsController userID];
    
    if ([existingUserId length]) {
        _localUser = [[CWDataManager sharedInstance] createUserWithID:existingUserId];
        return _localUser;
    }
    else {
        return nil;
    }
}

- (void)createNewLocalUser {
    
    NSString *newUserID = [[[NSUUID UUID] UUIDString] lowercaseString];
    NSLog(@"Generated new user id: %@",newUserID);
    
    self.localUser = [[CWDataManager sharedInstance] createUserWithID:newUserID];
    [CWUserDefaultsController setUserID:newUserID];
}

- (BOOL) hasApprovedProfilePicture:(User *) user
{
    BOOL approved = [[NSUserDefaults standardUserDefaults] boolForKey:kApprovedProfilePictureKey];
    return approved;
}

- (void) approveProfilePicture:(User *) user {
    
    if (!user) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kApprovedProfilePictureKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) hasUploadedProfilePicture:(User *) user
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:kUploadedProfilePictureKey] boolValue])

    {
        return YES;
    }
    return NO;
}

- (NSString *) getProfilePictureEndPointForUser:(User *) user
{
    NSString * user_id = user.userID;
    
    NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] putUserProfileEndPoint] , user_id];
    return endPoint;
}




- (void)uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user completion:(void (^)(NSError * error))completionBlock {
    
    if (![user.userID length]) {
        return;
    }
    
    [CWServerAPI uploadProfilePicture:thumbnail forUserID:user.userID withCompletionBlock:^(NSError *error) {

        if (error) {
            NSLog(@"Error: %@", error);
            
            if (completionBlock) {
                completionBlock(error);
            }
        } else {

            NSLog(@"Successfully upload profile picture for user: %@", user.userID);
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUploadedProfilePictureKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (completionBlock) {
                completionBlock(nil);
            }
        }
    }];
}


- (BOOL) shouldRequestAppFeedback
{
    if([self appVersionOfAppFeedbackRequest])
    {
        return NO;
    }
    NSInteger requestAppFeedbackThreshold = [[[CWGroundControlManager sharedInstance] appFeedbackSentMessageThreshold] integerValue];
    if(self.localUser.messagesSent.count < requestAppFeedbackThreshold)
    {
        return NO;
    }
    
    return YES;
}

- (void) didRequestAppFeedback
{
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

@end

