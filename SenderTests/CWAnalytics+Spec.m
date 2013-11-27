//
//  CWAnalytics+Spec.m
//  Sender
//
//  Created by Khalid on 11/27/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWAnalytics+Spec.h"
#import <objc/runtime.h>

static char FLAG_KEY;



@implementation CWAnalytics (Spec)
+(void)event:(NSString *)event withCategory:(NSString *)category withLabel:(NSString *)label withValue:(NSNumber *)value
{
    objc_setAssociatedObject(self, &FLAG_KEY, @(YES), OBJC_ASSOCIATION_ASSIGN);
    
}

+ (void)resetFlag
{
    objc_setAssociatedObject(self, &FLAG_KEY, @(NO), OBJC_ASSOCIATION_ASSIGN);
}
+ (BOOL)flagValue
{
    NSNumber * statusNum = objc_getAssociatedObject(self, &FLAG_KEY);
    return statusNum.boolValue;
}

@end
