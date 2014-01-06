//
//  CWAuthenticationManager.m
//  Sender
//
//  Created by Khalid on 11/21/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWAuthenticationManager.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "CWGoogleAuthViewController.h"

static NSString * SECRET = @"RqSWaMigfHYOiX1xwNiS1vNy";
static NSString * CLIENT_ID = @"910545881277.apps.googleusercontent.com";

static NSString * AuthKeyAccessToken    = @"accessToken";
static NSString * AuthKeyRefreshToken   = @"refreshToken";
static NSString * AuthKeyUserEmail      = @"userEmail";
static NSString * AuthKeyUserId         = @"userID";
static NSString * AuthKeyExpirationDate    = @"expirationDate";
static NSString * AuthKeyCode           = @"code";

#define DEBUG_AUTH (NO)


@interface CWAuthenticationManager ()
@property (nonatomic,assign) BOOL skippedAuth;
- (void)setAuth:(GTMOAuth2Authentication *)auth;
@end

@implementation CWAuthenticationManager

+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        if(DEBUG_AUTH)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auth"];
        }
    }
    return self;

}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
    } else {
        // Authentication succeeded
        self.auth = auth;
    }

}

- (GTMOAuth2ViewControllerTouch *)requestAuthentication
{
    NSError * err = nil;
    NSData * jsonData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"google_oauth2" withExtension:@"json"]];
    NSDictionary * jsonDict = [NSJSONSerialization  JSONObjectWithData:jsonData options:0 error:&err];
    NSAssert(err== nil, @"should have opened google auth file");
    NSAssert([jsonDict isKindOfClass:[NSDictionary class]], @"expecting dictionary");
    
    jsonDict = [jsonDict objectForKey:@"installed"];
    
    NSString * clientID = [jsonDict objectForKey:@"client_id"];
    NSString * secret = [jsonDict objectForKey:@"client_secret"];
//    NSString * authorizationURL = [jsonDict objectForKey:@"auth_uri"];
//    NSString * tokenURL = [jsonDict objectForKey:@"token_uri"];
//    NSString * redirectURL = [[jsonDict objectForKey:@"redirect_uris"]objectAtIndex:0];
    NSString * forAccountType = @"chatwala";
    
//    NSLog(@"extracted auth data");
    
    NSString *scope = @"https://www.googleapis.com/auth/userinfo.email";
    CWGoogleAuthViewController *viewController;
    
    viewController = [CWGoogleAuthViewController controllerWithScope:scope clientID:clientID clientSecret:secret keychainItemName:forAccountType completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
        //
        if(!error)
        {
            [self setAuth:auth];
        }
        NSLog(@"");
    }];
    
    __block CWGoogleAuthViewController * blockVC = viewController;
    
    [viewController setPopViewBlock:^{
        [self setSkippedAuth:YES];
        [blockVC.navigationController dismissViewControllerAnimated:YES completion:^{
            //
            
        }];
    }];
//    viewController = [[CWGoogleAuthViewController alloc] initWithScope:scope
//                                                                clientID:clientID
//                                                            clientSecret:secret
//                                                        keychainItemName:forAccountType
//                                                                delegate:self
//                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];

    return viewController;
    
}

- (void)setAuth:(GTMOAuth2Authentication *)auth
{
       NSDictionary * authDict = @{
                                AuthKeyAccessToken      : auth.accessToken,
                                AuthKeyRefreshToken     : auth.refreshToken,
                                AuthKeyExpirationDate   : auth.expirationDate,
                                AuthKeyCode             : auth.code,
                                AuthKeyUserEmail        : auth.userEmail,
                                AuthKeyUserId           : auth.userID
                                };
    
    [[NSUserDefaults standardUserDefaults]setObject:authDict forKey:@"auth"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //[CWAnalytics event:@"Finish Google Authentication" withCategory:@"Onboarding" withLabel:@"" withValue:nil];
    
    NSLog(@"user auhtentication data saved");
}

- (void)didFinishFirstRun
{
    [[NSUserDefaults standardUserDefaults]setValue:@(YES) forKey:@"firstRun"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    self.skippedAuth = NO;
    
}

- (void)didSkipAuth
{
    self.skippedAuth = YES;
}

- (BOOL)isFirstRun
{
    return [[NSUserDefaults standardUserDefaults]valueForKey:@"firstRun"] == nil;
}


- (BOOL)isAuthenticated
{
    return ([[NSUserDefaults standardUserDefaults]objectForKey:@"auth"] != nil);
}

- (BOOL)shouldShowAuth
{
    return NO;
    
    
    if ([self isAuthenticated]) {
        return NO;
    }
    
    
    if (self.skippedAuth) {
        return NO;
    }
    
    if ([self isFirstRun]) {
        return NO;
    }
    
    
    return YES;
}

- (NSString *)userEmail
{
    return [[[NSUserDefaults standardUserDefaults]objectForKey:@"auth"] objectForKey:AuthKeyUserEmail];
}

@end
