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


// FEEDBACK_REVIEW_STRING
- (NSString *)feedbackReviewString
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_REVIEW_STRING"];
}


// FEEDBACK_REACTION_STRING
- (NSString *)feedbackReactionString
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_REACTION_STRING"];
}
// FEEDBACK_RESPONSE_STRING
- (NSString *)feedbackResponseString
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_RESPONSE_STRING"];
}

// FEEDBACK_RECORDING_STRING
- (NSString *)feedbackRecordingString
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_RECORDING_STRING"];
}



@end
