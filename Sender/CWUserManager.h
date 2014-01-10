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
@property (nonatomic, readonly) User * localUser;

- (void) addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;

- (NSString *) userId;

@end
