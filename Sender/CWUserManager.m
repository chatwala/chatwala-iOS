//
//  CWUserManager.m
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWUserManager.h"

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
        NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
        if (!user_id) {
            [self getANewUserID];
        }else{
            NSLog(@"User already registered: %@",user_id);
        }
    }
    return self;
}

- (void)getANewUserID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://chatwala.azurewebsites.net/register" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSString * user_id =[responseObject valueForKey:@"user_id"];
        NSLog(@"User ID Fetched: %@",user_id);
        [[NSUserDefaults standardUserDefaults]setValue:user_id forKey:@"CHATWALA_USER_ID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@",error);
    }];
}

@end
