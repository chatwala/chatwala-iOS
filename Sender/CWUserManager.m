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


NSString * const kChatwalaAPIKey = @"58041de0bc854d9eb514d2f22d50ad4c";
NSString * const kChatwalaAPISecret = @"ac168ea53c514cbab949a80bebe09a8a";
NSString * const kChatwalaAPIKeySecretHeaderField = @"x-chatwala";

NSString * const UserIdDefaultsKey = @"CHATWALA_USER_ID";
NSString * const kAppVersionOfFeedbackRequestedKey  = @"APP_VERSION_WHEN_FEEDBACK_REQUESTED";


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
    
    NSString *existingUserId = [[NSUserDefaults standardUserDefaults] valueForKey:UserIdDefaultsKey];
    
    if ([existingUserId length]) {
        _localUser = [[CWDataManager sharedInstance] createUserWithID:existingUserId];
        return _localUser;
    }
    else {
        return nil;
    }
}

- (void)createNewLocalUser {
    
    NSString *newUserID = [[NSUUID UUID] UUIDString];
    NSLog(@"Generated new user id: %@",newUserID);
    
    self.localUser = [[CWDataManager sharedInstance] createUserWithID:newUserID];

    [[NSUserDefaults standardUserDefaults]setValue:newUserID forKey:UserIdDefaultsKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (BOOL)hasProfilePicture:(User *) user {

    NSString * const uploadedProfilePicture = @"profilePictureKey";
    if([[[NSUserDefaults standardUserDefaults] objectForKey:uploadedProfilePicture] boolValue])
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

- (void)uploadProfilePicture:(UIImage *)thumbnail forUser:(User *) user {
    [CWServerAPI uploadProfilePicture:thumbnail forUserID:user.userID withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            NSLog(@"Successfully upload profile picture for userID: %@", user.userID);
            NSString * const uploadedProfilePicture = @"profilePictureKey";

            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:uploadedProfilePicture];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
    if(self.localUser.messagesSent.count <= requestAppFeedbackThreshold)
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

@end

