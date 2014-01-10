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

NSString * const kChatwalaAPIKey = @"58041de0bc854d9eb514d2f22d50ad4c";
NSString * const kChatwalaAPISecret = @"ac168ea53c514cbab949a80bebe09a8a";
NSString * const kChatwalaAPIKeySecretHeaderField = @"x-chatwala";

@interface CWUserManager()

@property (nonatomic) User * localUser;

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

- (void) setupAuthentication
{
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", kChatwalaAPIKey, kChatwalaAPISecret];

    self.requestHeaderSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestHeaderSerializer setValue:keyAndSecret forHTTPHeaderField:kChatwalaAPIKeySecretHeaderField];
    
    NSString * user_id = [self userId];
    NSLog(@"User: %@",user_id);
    
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

- (NSString *) userId
{
    NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
    if(user_id)
    {
        self.localUser = [[CWDataManager sharedInstance] createUserWithID:user_id];
        return user_id;
    }
    [self getANewUserID];
    return @"unknown_user";
}


- (void)getANewUserID
{
    
    NSLog(@"getting new user id: %@",[[CWMessageManager sharedInstance] registerEndPoint]);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:self.requestHeaderSerializer];

    [manager GET:[[CWMessageManager sharedInstance] registerEndPoint]  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSString * user_id =[[responseObject valueForKey:@"user_id"]objectAtIndex:0];
        NSLog(@"New user ID Fetched: %@",user_id);
        [[NSUserDefaults standardUserDefaults]setValue:user_id forKey:@"CHATWALA_USER_ID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        self.localUser = [[CWDataManager sharedInstance] createUserWithID:user_id];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Operation: %@",operation);
        NSLog(@"Error: %@",error);
    }];
}

@end
