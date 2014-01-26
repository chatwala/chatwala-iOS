//
//  NSString+UUID.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)cw_UUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return uuidStr;
}

@end
