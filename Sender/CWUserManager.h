//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;
- (NSString *) userId;
@end
