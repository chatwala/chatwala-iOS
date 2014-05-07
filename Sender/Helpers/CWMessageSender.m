//
//  CWMessageSender.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/27/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWMessageSender.h"
#import "Message.h"
#import "CWDataManager.h"
#import "CWMessageManager.h"
#import "CWPushNotificationsAPI.h"
#import "CWUserManager.h"
#import "CWGroundControlManager.h"
#import "CWUserDefaultsController.h"
#import "CWConstants.h"
#import "CWVideoManager.h"

@interface CWMessageSender () <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic) MFMessageComposeViewController *messageComposer;
@property (nonatomic) MFMailComposeViewController *mailComposer;

@end

@implementation CWMessageSender

#pragma mark - Public API

- (void)sendMessageFromUser:(NSString *)userID {
    
    if (!self.delegate) {
        return;
    }
    else if (![self isValid]) {
        [self.delegate messageSender:self didFailMessageSend:nil];
    }
    
    if (self.messageBeingRespondedTo) {

        [[CWMessageManager sharedInstance] fetchUploadURLForReplyMessage:self.messageBeingSent completionBlockOrNil:^(Message *message, NSString *uploadURLString) {
            
            if (message && uploadURLString) {
                message.videoURL = [[[CWVideoManager sharedManager] recorder] outputFileURL];
                message.chatwalaZipURL = [NSURL fileURLWithPath:[[[CWVideoFileCache sharedCache] outBoxFilepathForKey:message.messageID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", message.messageID]]];
                self.messageBeingSent = message;
                
                [self.messageBeingSent exportZip];
                
                [[CWMessageManager sharedInstance] uploadMessage:self.messageBeingSent toURL:uploadURLString isReply:YES];
                [self didSendMessage];
            }
            else {
                
                if (self.delegate) {
                    
                    [self.delegate messageSender:self didFailMessageSend:[NSError errorWithDomain:@"MessageSender" code:0 userInfo:nil]];
                    [SVProgressHUD showErrorWithStatus:@"Message reply upload details not received."];
                }
            }
        }];
    }
    else {
        
        [[CWMessageManager sharedInstance] fetchUploadURLForOriginalMessage:userID completionBlockOrNil:^(Message *message, NSString *uploadURLString) {
            if (message) {

                message.videoURL = [[[CWVideoManager sharedManager] recorder] outputFileURL];
                message.chatwalaZipURL = [NSURL fileURLWithPath:[[[CWVideoFileCache sharedCache] outBoxFilepathForKey:message.messageID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", message.messageID]]];
                message.startRecording = [NSNumber numberWithDouble:0.0];
                self.messageBeingSent = message;
                
                [self.messageBeingSent exportZip];
                [[CWMessageManager sharedInstance] uploadMessage:self.messageBeingSent toURL:uploadURLString isReply:NO];
                
                // TODO: pass correct thang here...!
                [self composeMessageWithMessageKey:self.messageBeingSent.messageURL];
    
            }
            else {
                
                if (self.delegate) {    
                    [self.delegate messageSender:self didFailMessageSend:[NSError errorWithDomain:@"MessageSender" code:0 userInfo:nil]];
                    [SVProgressHUD showErrorWithStatus:@"Message upload details not received."];
                }
            }
        }];
    }
}

- (void)cancel {
    
    [self.messageComposer dismissViewControllerAnimated:NO completion:nil];
    [self.mailComposer dismissViewControllerAnimated:NO completion:nil];
    
    // We are throwing away this message - we should clear upload details in the event this was a original message
    [[CWMessageManager sharedInstance] clearUploadURLForOriginalMessage];
}

#pragma mark - Convenience methods

- (BOOL)isValid {
    
    BOOL validated = YES;
    
    if (!self.messageBeingSent) {
        validated = NO;
    }
    
    return validated;
}

- (void)composeMessageWithMessageKey:(NSString *)key {
    
    NSString *messagePrefix = nil;
#ifdef USE_QA_SERVER
    messagePrefix = @"This is a QA message";
#elif USE_DEV_SERVER
    messagePrefix = @"This is a DEV message";
#elif USE_SANDBOX_SERVER
    messagePrefix = @"This is a Sandbox message";
#elif USE_STAGING_SERVER
    messagePrefix = @"I sent you a Chatwala video";
#else
    messagePrefix = @"I sent you a Chatwala video";
#endif
    
    NSString *messageBody = [NSString stringWithFormat:@"%@: %@", messagePrefix, key];
    
    if ([[CWUserManager sharedInstance] newMessageDeliveryMethodIsSMS]) {
 
        self.messageComposer = [[MFMessageComposeViewController alloc] init];
        [self.messageComposer  setMessageComposeDelegate:self];
        [self.messageComposer  setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
        [self.messageComposer  setBody:messageBody];
        
        if (self.delegate) {
            [self.delegate messageSender:self shouldPresentMessageComposerController:self.messageComposer];
        }
    }
    else {
    
        // MAIL
        self.mailComposer = [[MFMailComposeViewController alloc] init];
        [self.mailComposer setMailComposeDelegate:self];
        [self.mailComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
        
        [[self mailComposer]  setMessageBody:[[CWGroundControlManager sharedInstance] emailMessage] isHTML:YES];
        [[self mailComposer]  setMessageBody:messageBody isHTML:NO];
        
        if (self.delegate) {
            [self.delegate messageSender:self shouldPresentMessageComposerController:self.mailComposer];
        }
    }
}

- (void)didSendMessage {
    
    self.messageBeingRespondedTo.eMessageViewedState = eMessageViewedStateReplied;
    
    // Move message from outbox to sent box
    [self moveMessageToSentBox];
    
    [[NSUserDefaults standardUserDefaults]setValue:@(YES) forKey:@"MESSAGE_SENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [CWAnalytics messageSentWithID:self.messageBeingSent.messageID isReply:(self.messageBeingRespondedTo != nil)];
    
    NSInteger currentSentCount = [CWUserDefaultsController numberOfSentMessages];
    [CWUserDefaultsController setNumberOfSentMessages:++currentSentCount];
    [NC postNotificationName:CWNotificationMessageSent object:nil];
    
    if (self.delegate) {
        [self.delegate messageSenderDidSucceedMessageSend:self forMessage:self.messageBeingSent];
        self.delegate = nil;
    }
    
    [self.messageComposer dismissViewControllerAnimated:YES completion:nil];
    [self.mailComposer dismissViewControllerAnimated:YES completion:nil];
    
    [CWPushNotificationsAPI registerForPushNotifications];
}

- (void)moveMessageToSentBox {
    
    NSError *error = nil;
    NSString * localPath = [[CWVideoFileCache sharedCache] sentBoxFilepathForKey:self.messageBeingSent.messageID];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating sent file directory: %@", error.debugDescription);
        }
    }
    
    NSURL *destinationURL = [NSURL fileURLWithPath:[[[CWVideoFileCache sharedCache] sentBoxFilepathForKey:self.messageBeingSent.messageID] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",self.messageBeingSent.messageID]]];

    [[NSFileManager defaultManager] moveItemAtURL:[Message outboxChatwalaZipURL:self.messageBeingSent.messageID] toURL:destinationURL error:&error];

    [[NSFileManager defaultManager] removeItemAtPath:[[CWVideoFileCache sharedCache] outBoxFilepathForKey:self.messageBeingSent.messageID]  error:nil];
    self.messageBeingSent.chatwalaZipURL = destinationURL;
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultSent:
        
            [self didSendMessage];
            break;
            
        case MFMailComposeResultCancelled:
            if (self.messageBeingRespondedTo) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Message" withLabel:@"" withValue:nil];
            }
            
            if (self.delegate) {
                [self.delegate messageSenderDidCancelMessageSend:self];
                self.delegate = nil;
            }
            
            [self cancel];
            break;
        default:
            break;
    }
    
    [self.mailComposer dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    switch (result) {
        case MessageComposeResultSent:
            
            [self didSendMessage];
            break;
            
        case MessageComposeResultCancelled:
            if (self.messageBeingRespondedTo) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }
            else {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            
            if (self.delegate) {
                [self.delegate messageSenderDidCancelMessageSend:self];
                self.delegate = nil;
            }

            [self cancel];
            break;
        default:
            break;
    }
    
    
}

@end