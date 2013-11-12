//
//  AVURLAsset+Spec.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "AVURLAsset+Spec.h"
#import <objc/runtime.h>
static char COMPLETION_KEY;
static char SUCCESS_KEY;
static char FAILURE_KEY;


@implementation AVURLAsset (Spec)
- (void)loadValuesAsynchronouslyForKeys:(NSArray *)keys completionHandler:(void (^)(void))handler
{
    objc_setAssociatedObject(self, &COMPLETION_KEY, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)completeWithSuccessKeys:(NSArray *)successKeys failureKeys:(NSArray *)failureKeys {
    objc_setAssociatedObject(self, &SUCCESS_KEY, successKeys, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &FAILURE_KEY, failureKeys, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    void (^callback)(void) = objc_getAssociatedObject(self, &COMPLETION_KEY);
    
    
    callback();
    
}
- (AVKeyValueStatus)statusOfValueForKey:(NSString *)key error:(NSError *__autoreleasing *)outError
{
    NSArray * successKeys = objc_getAssociatedObject(self, &SUCCESS_KEY);
    NSArray * failureKeys = objc_getAssociatedObject(self, &FAILURE_KEY);
    if([successKeys containsObject:key])
    {
        return AVKeyValueStatusLoaded;
    }else if([failureKeys containsObject:key]){
        return AVKeyValueStatusFailed;
    }
    else
    {
        NSLog(@"missing key: %@",key);
        if(outError)
        {
            *outError = [NSError errorWithDomain:@"something" code:5 userInfo:nil];
        }
    }
    return AVKeyValueStatusUnknown;
    
}

@end
