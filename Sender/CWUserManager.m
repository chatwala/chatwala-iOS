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
        [self setupHttpAuthHeaders];

        if (!self.localUserID) {
            [self createNewLocalUser];
        }
    }
    return self;
}

- (void)setupHttpAuthHeaders {
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", CWConstantsChatwalaAPIKey, CWConstantsChatwalaAPISecret];

    self.requestHeaderSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestHeaderSerializer setValue:keyAndSecret forHTTPHeaderField:CWConstantsChatwalaAPIKeySecretHeaderField];
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
    
    NSString *newUserID = @"d80ba84b-7785-c219-5ee5-74130eff8e2a"; [[[NSUUID UUID] UUIDString] lowercaseString];
    NSLog(@"Generated new user id: %@",newUserID);
    
    //self.localUser = [[CWDataManager sharedInstance] createUserWithID:newUserID];
    [CWUserDefaultsController setUserID:newUserID];
}

- (BOOL) hasApprovedProfilePicture:(NSString *) user
{
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

- (BOOL) hasUploadedProfilePicture:(NSString *)userID
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:kUploadedProfilePictureKey] boolValue])

    {
        return YES;
    }
    return NO;
}

- (NSString *) getProfilePictureEndPointForUser:(NSString *)userID {
    //NSString * user_id = user.userID;
    
    //NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] putUserProfileEndPoint] , user_id];
    return nil;
}


- (void)uploadProfilePicture:(UIImage *) thumbnail forUser:(NSString *)userID completion:(void (^)(NSError * error))completionBlock {
    
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

            NSLog(@"Successfully upload profile picture for user: %@", userID);
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
    if([self numberOfSentMessages] < requestAppFeedbackThreshold)
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

- (NSInteger) numberOfUnreadMessages {
    
    // TODO:
    return 0;
}

- (NSInteger)numberOfSentMessages {

    // TODO:
    return 0;
}

+ (NSArray *)messagesForUser:(NSString *)userID {

    NSManagedObjectContext *moc = [[CWDataManager sharedInstance] moc];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(senderID == %@)", userID];
    [request setPredicate:predicate];
    
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    if (array) {
        return array;
    }
    else {
        return nil;
    }
}

@end

