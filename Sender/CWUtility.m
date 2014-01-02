//
//  CWUtility.m
//  Sender
//
//  Created by randall chatwala on 12/31/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWUtility.h"

@implementation CWUtility
+ (NSURL*)cacheDirectoryURL
{
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

@end
