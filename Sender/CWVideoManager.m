//
//  CWVideoManager.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoManager.h"

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
        self.recorder = [[NSObject alloc]init];
        self.player = [[NSObject alloc]init];
    }
    return self;
}

@end
