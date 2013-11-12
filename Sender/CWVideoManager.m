//
//  CWVideoManager.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoManager.h"

@interface CWVideoManager ()

@end


@implementation CWVideoManager
+(instancetype) sharedManager {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}

- (id)init
{
    self=[super init];
    if (self) {
        self.recorder = [[CWVideoRecorder alloc]init];
        self.player = [[CWVideoPlayer alloc]init];
    }
    return self;
}


@end
