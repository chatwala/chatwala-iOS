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
        [self refresh];
    }
    return self;
}

- (void)refresh
{
    NSURL *URL = [NSURL URLWithString:@"https://s3.amazonaws.com/downloads.apporchard.com/pho/defaults.plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL];
}

- (NSString *)tapToPlayVideo
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"TAP_TO_PLAY_VIDEO"];
    return value ? value:@"Tap To Play";
}


// FEEDBACK_REVIEW_STRING
- (NSString *)feedbackReviewString
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_REVIEW_STRING"];
    return value ? value:@"Recording Reaction in 0:%02d";
}


// FEEDBACK_REACTION_STRING
- (NSString *)feedbackReactionString
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_REACTION_STRING"];
    return value ? value:@"Recording Reaction 0:%02d";
}

// FEEDBACK_RESPONSE_STRING
- (NSString *)feedbackResponseString
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_RESPONSE_STRING"];
    return value ? value:@"Recording Response 0:%02d";
}

// FEEDBACK_RECORDING_STRING
- (NSString *)feedbackRecordingString
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"FEEDBACK_RECORDING_STRING"];
    return value ? value:@"Recording 0:%02d";
    
}
// START_SCREEN_MESSAGE
- (NSString *)startScreenMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"START_SCREEN_MESSAGE"];
    return value ? value:@"Tap to record and send a message. Your friend’s reaction will show here when they receive your message and reply.";
}

@end
