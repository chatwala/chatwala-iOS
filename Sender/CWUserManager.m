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

- (void) setupAuthentication
{
    
    NSString * keyAndSecret = [NSString stringWithFormat:@"%@:%@", kChatwalaAPIKey, kChatwalaAPISecret];

    self.requestHeaderSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestHeaderSerializer setValue:keyAndSecret forHTTPHeaderField:kChatwalaAPIKeySecretHeaderField];
    
    [self localUser:^(User *localUser) {
        NSLog(@"User: %@",localUser.userID);
    }];
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




- (void) localUser:(void (^)(User *localUser)) completion
{
    NSString * const kUserIDKey = @"CHATWALA_USER_ID";
    
    NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:kUserIDKey];
    if(user_id)
    {
        self.localUser = [[CWDataManager sharedInstance] createUserWithID:user_id];
        if(completion)
        {
            completion(self.localUser);
        }
    }
    else
    {
        [self getANewUserID:completion];
    }
}

- (void)getANewUserID:(CWUserManagerLocalUserBlock) completion
{
    NSLog(@"getting new user id: %@",[[CWMessageManager sharedInstance] registerEndPoint]);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:self.requestHeaderSerializer];

    [self.fetchUserIDOperation setCompletionBlockWithSuccess:nil failure:nil];
    [self.fetchUserIDOperation cancel];
    
    self.fetchUserIDOperation = [manager GET:[[CWMessageManager sharedInstance] registerEndPoint]  parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        self.getUserIDCompletionBlock(operation, responseObject, completion);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Operation: %@",operation);
        NSLog(@"Error: %@",error);
    }];
}

- (CWUserManagerGetUserIDFetchBlock) getUserIDCompletionBlock
{
    return (^ void(AFHTTPRequestOperation *operation, id responseObject, CWUserManagerLocalUserBlock completion){
        NSAssert([responseObject isKindOfClass:[NSArray class]], @"expecting an array. found %@",responseObject);
        NSDictionary * dictionary = [responseObject objectAtIndex:0];
        NSAssert([dictionary isKindOfClass:[NSDictionary class]], @"expecting a dictionary in the array. found %@", dictionary);
        NSString * user_id =[dictionary objectForKey:@"user_id"];
        NSAssert([user_id isKindOfClass:[NSString class]], @"expecting a string for the 'user_id' key. found %@", user_id);
        NSLog(@"New user ID Fetched: %@",user_id);
        [[NSUserDefaults standardUserDefaults]setValue:user_id forKey:@"CHATWALA_USER_ID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        self.localUser = [[CWDataManager sharedInstance] createUserWithID:user_id];
        if(completion)
        {
            completion(self.localUser);
        }
        
    });
}



@end
