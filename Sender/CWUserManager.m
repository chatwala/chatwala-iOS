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
        NSString * user_id = [self userId];
        NSLog(@"User: %@",user_id);
    }
    return self;
}
- (NSString *) userId
{
    NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
    if(user_id)
    {
        [self getUserMessages:user_id];
        return user_id;
    }
    [self getANewUserID];
    return @"unkown_user";
}


- (void)getUserMessages:(NSString*)user_id
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * url = [NSString stringWithFormat:@"%@/users/%@/messages",BASE_URL_ENDPOINT,user_id] ;
    NSLog(@"fetching messages: %@",url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSLog(@"fetched user messages: %@",responseObject);
        NSArray * messages = [responseObject objectForKey:@"messages"];
//        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:messages.count];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        NSLog(@"failed to fecth messages");
    }];
}

- (void)getANewUserID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:REGISTER_ENDPOINT  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
