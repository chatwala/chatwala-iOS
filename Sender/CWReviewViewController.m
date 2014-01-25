//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWFlowManager.h"
#import "AppDelegate.h"
#import "CWLandingViewController.h"
#import "CWGroundControlManager.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import "CWUtility.h"
#import "User.h"
#import "Message.h"
#import "Thread.h"
#import "CWPushNotificationsAPI.h"

@interface CWReviewViewController () <UINavigationControllerDelegate,CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSInteger playbackCount;
 
}
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) MFMailComposeViewController *mailComposer;
@end

@implementation CWReviewViewController

@synthesize player;
@synthesize recorder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    player =[[CWVideoManager sharedManager]player];
    recorder = [[CWVideoManager sharedManager]recorder];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToBackground)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    [self setNavMode:NavModeClose];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    playbackCount = 0;
    [player setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [player setVideoURL:recorder.tempFileURL];
}


- (void)goToBackground
{
    if (self.mailComposer) {
        [[self mailComposer]dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)composeMessageWithMessageKey:(NSString*)messageURL withCompletion:(void (^)(void))completion
{
    if([MFMessageComposeViewController canSendText])
    {
        // SMS
        MFMessageComposeViewController  * smsComposer = [[MFMessageComposeViewController alloc] init];
        [smsComposer setMessageComposeDelegate:self];
        [smsComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
        [smsComposer setBody:[NSString stringWithFormat:@"Hey, I sent you a video message on Chatwala: %@",messageURL]];
        
        [self presentViewController:smsComposer  animated:YES completion:completion];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"SMS/iMessage currently unavailable"];
    }
    
    /*
    // MAIL
    self.mailComposer = [[MFMailComposeViewController alloc] init];
    [self.mailComposer setMailComposeDelegate:self];
    [self.mailComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
    
    
    if (self.incomingMessageItem.metadata.senderId) {
        [[self mailComposer] setToRecipients:@[self.incomingMessageItem.metadata.senderId]];
    }
    
//    [[self mailComposer]  setMessageBody:[[CWGroundControlManager sharedInstance] emailMessage] isHTML:YES];
    [[self mailComposer]  setMessageBody:messageURL isHTML:NO];
    
//    [[self mailComposer]  addAttachmentData:messageData mimeType:@"application/octet-stream" fileName:@"chat.wala"];
    [self presentViewController:[self mailComposer]  animated:YES completion:nil];
    
    */
}


- (CWMessageItem*)createMessageItemWithSender:(User*) localUser
{
    CWMessageItem * message = [[CWMessageItem alloc]initWithSender:localUser];
    [message setVideoURL:recorder.outputFileURL];
    message.metadata.startRecording = self.startRecordingTime;
    
    
//    if ([[CWAuthenticationManager sharedInstance]isAuthenticated]) {
//        [message.metadata setSenderId:[[CWAuthenticationManager sharedInstance] userEmail]];
//    }
    
    if (self.incomingMessage) {
        
        [message.metadata setRecipientId:self.incomingMessage.sender.userID];
        [message.metadata setThreadId:self.incomingMessage.thread.threadID];
        [message.metadata setThreadIndex:self.incomingMessage.threadIndexValue + 1];
    }
    return message;
}


- (void)onTap:(id)sender
{
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    
    if (self.incomingMessage) {
        // responding
        
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
//    [super onTap:sender];
}


- (IBAction)onRecordAgain:(id)sender {
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    
    if (self.incomingMessage) {
        // responding
        
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    
    
}

#pragma mark - Message Sending

- (IBAction)onSend:(id)sender {
    
    if (self.sendButton.buttonState == eButtonStateBusy) {
        return;
    }
    
    
    [player stop];

    //    [self composeMessageWithData:[self createMessageData]];
    [self.sendButton setButtonState:eButtonStateBusy];
    
    [[CWUserManager sharedInstance] localUser:^(User *localUser) {
        [self sendMessageFromUser:localUser];
    }];
}

- (void) sendMessageFromUser:(User *) localUser
{
    CWMessageItem * message = [self createMessageItemWithSender:localUser];
    
    if (self.incomingMessage) {
        // Responding to an incoming message
        [CWAnalytics event:@"SEND_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        
        [[CWMessageManager sharedInstance] fetchMessageIDForReplyToMessage:message completionBlockOrNil:^(NSString *messageID, NSString *messageURL) {
            if (messageID && messageURL) {
                message.metadata.messageId = messageID;
                
                [message exportZip];
                [[CWMessageManager sharedInstance] uploadMessage:message isReply:YES];
                [self.sendButton setButtonState:eButtonStateShare];
                [self didSendMessage];
                [CWAnalytics event:@"SENT_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
            }
            else {
                if(!messageID)
                {
                    [SVProgressHUD showErrorWithStatus:@"Failed to get a messageID"];
                }
                else if(!messageID)
                {
                    [SVProgressHUD showErrorWithStatus:@"Failed to get a messageURL"];
                }
            }
        }];
        
    }else{
        // Original message send
        
        [CWAnalytics event:@"SEND_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];
        [[CWMessageManager sharedInstance] fetchOriginalMessageIDWithSender:localUser completionBlockOrNil:^(NSString *messageID, NSString *messageURL) {
            
            if (messageID && messageURL) {
                message.metadata.messageId = messageID;
                
                [self composeMessageWithMessageKey:messageURL withCompletion:^{
                    [message exportZip];
                    [[CWMessageManager sharedInstance] uploadMessage:message isReply:NO];
                }];
            }
            else {
                if(!messageID)
                {
                    [SVProgressHUD showErrorWithStatus:@"Failed to get a messageID"];
                }
                else if(!messageID)
                {
                    [SVProgressHUD showErrorWithStatus:@"Failed to get a messageURL"];
                }
            }
        }];
    }
}

- (void) uploadProfilePictureForUser:(User *) user
{
    
    if([[CWUserManager sharedInstance] hasProfilePicture:user])
    {
        return;//already did this
    }
    
    [self.player createThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
        [[CWUserManager sharedInstance] uploadProfilePicture:thumbnail forUser:user];
    }];
    
}

- (void) didSendMessage
{
    
    [[CWUserManager sharedInstance] localUser:^(User *localUser) {
        [self uploadProfilePictureForUser:localUser];
    }];

    [CWPushNotificationsAPI registerForPushNotifications];
    
    
    [[NSUserDefaults standardUserDefaults]setValue:@(YES) forKey:@"MESSAGE_SENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
//    [[CWAuthenticationManager sharedInstance]didSkipAuth];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer
{
    [self showVideoPreview];
}

- (void)showVideoPreview
{
//    [self.view insertSubview:self.player.playbackView belowSubview:self.recordAgainButton];
    [self.previewView addSubview:player.playbackView];
    self.previewView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5);
    player.playbackView.frame = self.previewView.bounds;
    
    
    [player playVideo];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    playbackCount++;
    [player replayVideo];
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self.sendButton setButtonState:eButtonStateShare];
    
    switch (result) {
        case MFMailComposeResultSent:
            {
                if (self.incomingMessage) {
                    [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
                }else{
                    [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Message" withLabel:@"" withValue:nil];
                }
                [self didSendMessage];
            }
            break;
    
        case MFMailComposeResultCancelled:
            if (self.incomingMessage) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Message" withLabel:@"" withValue:nil];
            }
            [self.player replayVideo];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.mailComposer= nil;
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.sendButton setButtonState:eButtonStateShare];
    
    switch (result) {
        case MessageComposeResultSent:
        {
            if (self.incomingMessage) {
                [CWAnalytics event:@"MESSAGE_SENT" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_SENT" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            
            [self didSendMessage];
        }
            break;
            
        case MessageComposeResultCancelled:
            if (self.incomingMessage) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            [self.player replayVideo];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
