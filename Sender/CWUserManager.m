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
#import "NSString+UUID.h"

NSString * const kChatwalaAPIKey = @"58041de0bc854d9eb514d2f22d50ad4c";
NSString * const kChatwalaAPISecret = @"ac168ea53c514cbab949a80bebe09a8a";
NSString * const kChatwalaAPIKeySecretHeaderField = @"x-chatwala";
NSString * const UserIdDefaultsKey = @"CHATWALA_USER_ID";


@interface CWUserManager()

@property (nonatomic) User *localUser;
@property (nonatomic) AFHTTPRequestOperation * fetchUserIDOperation;
@end

@implementation CWUserManager
+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupAuthentication];
    }
    return self;
}

- (void)setupAuthentication
{
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", kChatwalaAPIKey, kChatwalaAPISecret];

    self.requestHeaderSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestHeaderSerializer setValue:keyAndSecret forHTTPHeaderField:kChatwalaAPIKeySecretHeaderField];
    
    NSLog(@"User: %@",self.localUser.userID);
}

- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request
{
    NSDictionary * headerDictionary = [[[CWUserManager sharedInstance] requestHeaderSerializer] HTTPRequestHeaders];
    for (NSString * key in headerDictionary) {
        NSAssert([key isKindOfClass:[NSString class]], @"expecting strings for the keys of the request header. found: %@", key);
        NSString* value = [headerDictionary objectForKey:key];
        NSAssert([value isKindOfClass:[NSString class]], @"expecting strings for the values of the request header. found: %@", value);
        
        [request addValue:value forHTTPHeaderField:key];
    }

}

- (BOOL)hasLocalUser {
    return (self.localUser ? YES : NO);
}

- (User *)localUser {
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:UserIdDefaultsKey];

    if([user_id length]) {
        self.localUser = [[CWDataManager sharedInstance] createUserWithID:user_id];
    }
    else {
        self.localUser = [self createNewUser];
    }
    
    return self.localUser;
}

- (User *)createNewUser {
    
    NSString *newUserID = [NSString cw_UUID];
    NSLog(@"Generated new user id: %@",newUserID);
    
    User *user = [[CWDataManager sharedInstance] createUserWithID:newUserID];
    
    if (user) {
        [[NSUserDefaults standardUserDefaults]setValue:newUserID forKey:UserIdDefaultsKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    return user;
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

- (void) uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user
{
    NSString * const uploadedProfilePicture = @"profilePictureKey";

    NSLog(@"thumbnail created:%@", thumbnail);
    
    NSURL * thumbnailURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"thumbnailImage.png"];
    [UIImageJPEGRepresentation(thumbnail, 1.0) writeToURL:thumbnailURL atomically:YES];
    
    NSString * user_id = user.userID;
    
    NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] putUserProfileEndPoint] , user_id];
    NSLog(@"uploading profile image: %@",endPoint);
    NSURL *URL = [NSURL URLWithString:endPoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
    
    AFURLSessionManager * mgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask * task = [mgr uploadTaskWithRequest:request fromFile:thumbnailURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        //
        if (error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            NSLog(@"Successfully upload profile picture: %@ %@", response, responseObject);
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:uploadedProfilePicture];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
    [task resume];

}

@end
