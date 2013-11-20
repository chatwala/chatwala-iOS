//
//  CWGroundControlManager.m
//  Sender
//
//  Created by Khalid on 11/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWGroundControlManager.h"

@implementation CWGroundControlManager
+(instancetype) sharedInstance {
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
    if (self)
    {
        NSURL *URL = [NSURL URLWithString:@"https://s3.amazonaws.com/downloads.apporchard.com/pho/defaults.plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL];
    }
    return self;
}

- (NSString *)tapToPlayVideo
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"TAP_TO_PLAY_VIDEO"];
}

@end
