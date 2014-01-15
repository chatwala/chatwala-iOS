//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;

- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;

@property (nonatomic, readonly) User * localUser __attribute__((deprecated("use localUser:")));
- (NSString *) userId __attribute__((deprecated("use localUser:")));

- (void) localUser:(void (^)(User *localUser)) completion;


@end
