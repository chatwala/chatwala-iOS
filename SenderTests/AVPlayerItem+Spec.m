//
//  AVPlayerItem+Spec.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "AVPlayerItem+Spec.h"
#import <objc/runtime.h>

static char STATUS_KEY;

@implementation AVPlayerItem (Spec)

- (void)setStatus:(AVKeyValueStatus)status
{
    [self willChangeValueForKey:@"status"];
    objc_setAssociatedObject(self, &STATUS_KEY, @(status), OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"status"];
}

- (AVPlayerItemStatus)status
{
    NSNumber * statusNum = objc_getAssociatedObject(self, &STATUS_KEY);
    return statusNum.intValue;
}
@end
