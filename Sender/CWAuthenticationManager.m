//
//  CWAuthenticationManager.m
//  Sender
//
//  Created by Khalid on 11/21/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWAuthenticationManager.h"
#import "GTMOAuth2ViewControllerTouch.h"

static NSString * SECRET = @"RqSWaMigfHYOiX1xwNiS1vNy";
static NSString * CLIENT_ID = @"910545881277.apps.googleusercontent.com";


@interface CWAuthenticationManager ()
@property (nonatomic,strong)GTMOAuth2Authentication * auth;


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

+ (void)initialize
{
    

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
    [viewController dismissViewControllerAnimated:YES completion:nil];
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
    NSString * authorizationURL = [jsonDict objectForKey:@"auth_uri"];
    NSString * tokenURL = [jsonDict objectForKey:@"token_uri"];
    NSString * redirectURL = [[jsonDict objectForKey:@"redirect_uris"]objectAtIndex:0];
    NSString * forAccountType = @"chatwala";
    
    NSLog(@"extracted auth data");
    
    NSString *scope = @"https://www.googleapis.com/auth/userinfo.email";
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                clientID:clientID
                                                            clientSecret:secret
                                                        keychainItemName:forAccountType
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];

    return viewController;
    
}

@end
