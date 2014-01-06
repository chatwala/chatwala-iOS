//
//  CWUserManager.m
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWUserManager.h"
#import "CWMessageManager.h"

NSString * const kChatwalaAPIKey = @"123456789";
NSString * const kChatwalaAPISecret = @"qwertyuiop";
NSString * const kChatwalaAPIKeySecretHeaderField = @"x-chatwala";

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

- (void) setupAuthentication
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", kChatwalaAPIKey, kChatwalaAPISecret];

    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue:keyAndSecret forHTTPHeaderField:kChatwalaAPIKeySecretHeaderField];
    
    NSString * user_id = [self userId];
    NSLog(@"User: %@",user_id);
    
}

- (NSString *) userId
{
    NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
    if(user_id)
    {
        return user_id;
    }
    [self getANewUserID];
    return @"unknown_user";
}


- (void)getANewUserID
{
    
    NSLog(@"getting new user id: %@",[[CWMessageManager sharedInstance] registerEndPoint]);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[[CWMessageManager sharedInstance] registerEndPoint]  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSString * user_id =[[responseObject valueForKey:@"user_id"]objectAtIndex:0];
        NSLog(@"New user ID Fetched: %@",user_id);
        [[NSUserDefaults standardUserDefaults]setValue:user_id forKey:@"CHATWALA_USER_ID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
}

@end
