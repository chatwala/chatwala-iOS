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
    NSURL *URL = [NSURL URLWithString:@"https://s3.amazonaws.com/chatwala.groundcontrol/defaults.plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:URL success:^(NSDictionary *defaults) {
        NSLog(@"succesful ground control update");
    } failure:^(NSError *error) {
        NSAssert(0==1, @"ground control update failed:%@",error);
    }];
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
    return value ? value:@"Tap to record and send a message. Your friend's reaction will appear here when they reply.";
}

// OPENER_SCREEN_MESSAGE
- (NSString *)openerScreenMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"OPENER_SCREEN_MESSAGE"];
    return value ? value:@"Play your friend's message and record your reaction.\nThen reply, preview & send it!";
}

// ERROR_SCREEN_MESSAGE_MIC_COMPOSER
- (NSString*)composerMicErrorScreenMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"ERROR_SCREEN_MESSAGE_MIC_COMPOSER"];
    return value ? value:@"Chatwala can't access your microphone. Go to your Settings → Privacy → Microphone to enable access.";
}

// ERROR_SCREEN_MESSAGE_MIC_OPENER
- (NSString*)openerMicErrorScreenMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"ERROR_SCREEN_MESSAGE_MIC_OPENER"];
    return value ? value:@"Chatwala can't access your microphone. Go to your Settings → Privacy → Microphone to enable access.";
}
// EMAIL_MESSAGE
- (NSString *)emailMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"EMAIL_MESSAGE"];
    return value ? value:@"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml'><head><meta name='viewport' content='width=device-width' /><meta http-equiv='Content-Type' content='text/html; charset=UTF-8' /><title>Chatwala Message</title><link rel='stylesheet' type='text/css' href='stylesheets/email.css' /></head><body bgcolor='#FFFFFF'><p class='callout'>Chatwala is a new way to have real conversations with friends. <a href='http://chatwala.com'>Get the App.</a></p></body></html>";
}

// SMS_MESSAGE
- (NSString *)smsMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"SMS_MESSAGE"];
    return value ? value:@"";
}

// EMAIL_SUBJECT
- (NSString *)emailSubject
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"EMAIL_SUBJECT"];
    return value ? value:@"Chatwala message";
}


// REPLY_MESSAGE
- (NSString *)replyMessage
{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"REPLY_MESSAGE"];
    return value ? value:@"Now Reply!";
}

@end
