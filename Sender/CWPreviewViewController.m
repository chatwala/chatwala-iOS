//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWPreviewViewController.h"
#import "CWVideoManager.h"
#import "AppDelegate.h"
#import "CWGroundControlManager.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import "CWUtility.h"
#import "User.h"
#import "Message.h"
#import "Thread.h"
#import "CWPushNotificationsAPI.h"
#import "CWDataManager.h"
#import "CWAnalytics.h"

@interface CWPreviewViewController () <UINavigationControllerDelegate,CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSInteger playbackCount;
 
}
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) MFMailComposeViewController *mailComposer;
@property (nonatomic,strong) MFMessageComposeViewController *messageComposer;

@end

@implementation CWPreviewViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    self.incomingMessageStillImageView.image = self.incomingMessage.lastFrameImage;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];

    if ([player.delegate isEqual:self])
    {
        [player cleanUp];
        player.delegate = nil;
        player = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) appHasGoneInBackground:(NSNotification*)notification
{
    [self.messageComposer dismissViewControllerAnimated:NO completion:nil];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)goToBackground
{
    if (self.mailComposer) {
        [[self mailComposer]dismissViewControllerAnimated:NO completion:nil];
    }
}


- (void)composeMessageWithMessageKey:(NSString *)messageURL withCompletion:(void (^)(void))completion {
    
    
    NSString *messagePrefix = nil;
#ifdef USE_QA_SERVER
    messagePrefix = @"This is a QA message";
#elif USE_DEV_SERVER
    messagePrefix = @"This is a DEV message";
#elif USE_SANDBOX_SERVER
    messagePrefix = @"This is a Sandbox message";
#elif USE_STAGING_SERVER
    messagePrefix = @"Hey, I sent you a video message on Chatwala";
#else
    messagePrefix = @"Hey, I sent you a video message on Chatwala";
#endif

    NSString *messageBody = [NSString stringWithFormat:@"%@: %@", messagePrefix, messageURL];
    
    if ([[CWUserManager sharedInstance] newMessageDeliveryMethodIsSMS])
    {
        if([MFMessageComposeViewController canSendText] ) {
            self.messageComposer = [[MFMessageComposeViewController alloc] init];
            [self.messageComposer  setMessageComposeDelegate:self];
            [self.messageComposer  setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
            [self.messageComposer  setBody:messageBody];

            [self presentViewController:self.messageComposer   animated:YES completion:completion];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"SMS/iMessage currently unavailable"];
        }
    }
    else
    {
        if ([MFMailComposeViewController canSendMail]) {
            // MAIL
            self.mailComposer = [[MFMailComposeViewController alloc] init];
            [self.mailComposer setMailComposeDelegate:self];
            [self.mailComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];

            [[self mailComposer]  setMessageBody:[[CWGroundControlManager sharedInstance] emailMessage] isHTML:YES];
            [[self mailComposer]  setMessageBody:messageBody isHTML:NO];

            //    [[self mailComposer]  addAttachmentData:messageData mimeType:@"application/octet-stream" fileName:@"chat.wala"];
            [self presentViewController:[self mailComposer]  animated:YES completion:completion];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Email currently unavailable"];
        }
    }
}

// TODO: Poorly named - this is the 'X' button firing when user is discarding their message.
- (void)onTap:(id)sender
{
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    
    // We are throwing away this message - we should clear upload details in the event this was a original message
    [[CWMessageManager sharedInstance] clearUploadURLForOriginalMessage];
    
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
    [self sendMessageFromUser:[[CWUserManager sharedInstance] localUser]];
}

- (void)sendMessageFromUser:(User *)localUser {
    Message * message = [[CWDataManager sharedInstance] createMessageWithSender:localUser inResponseToIncomingMessage:self.incomingMessage];
    
    message.videoURL = recorder.outputFileURL;
    message.zipURL = [NSURL fileURLWithPath:[[CWDataManager cacheDirectoryPath]stringByAppendingPathComponent:MESSAGE_FILENAME]];
    message.startRecording = [NSNumber numberWithDouble:self.startRecordingTime];

    
    if (self.incomingMessage) {
        // Responding to an incoming message
        [CWAnalytics event:@"SEND_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        
        [[CWMessageManager sharedInstance] fetchUploadURLForReplyMessage:message completionBlockOrNil:^(NSString *messageID, NSString *uploadURLString, NSString *downloadURLString) {
            if (messageID && uploadURLString ) {
                message.messageID = messageID;
                [message exportZip];
                
                [[CWMessageManager sharedInstance] uploadMessage:message toURL:uploadURLString isReply:YES];
                [self.sendButton setButtonState:eButtonStateShare];
                [self didSendMessage];
                [CWAnalytics event:@"SENT_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Message upload details not recieved."];
            }
        }];
    }else{
        // New conversation starter message
        
        [CWAnalytics event:@"SEND_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];

        [[CWMessageManager sharedInstance] fetchUploadURLForOriginalMessage:localUser completionBlockOrNil:^(NSString *messageID, NSString *uploadURLString, NSString *downloadURLString) {
            if (uploadURLString && messageID && downloadURLString) {
                
                message.messageID = messageID;
                
#ifdef USE_QA_SERVER
                downloadURLString = [NSString stringWithFormat:@"http://chatwala.com/qa/?%@",messageID];
#elif USE_DEV_SERVER
                downloadURLString = [NSString stringWithFormat:@"http://chatwala.com/dev/?%@",messageID];
#endif
                
                
                [self composeMessageWithMessageKey:downloadURLString withCompletion:^{
                    [message exportZip];
                    [[CWMessageManager sharedInstance] uploadMessage:message toURL:uploadURLString isReply:NO];
                }];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Message upload details not recieved."];
            }
        }];
    }
}

- (void)uploadProfilePictureForUser:(User *) user {
    
    if([[CWUserManager sharedInstance] hasUploadedProfilePicture:user]) {
        return;//already did this
    }
    
    [self.player createProfilePictureThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
        [[CWUserManager sharedInstance] uploadProfilePicture:thumbnail forUser:user completion:nil];
    }];
    
}

- (void) didSendMessage {
    
    [self uploadProfilePictureForUser:[[CWUserManager sharedInstance] localUser]];
    
    self.incomingMessage.eMessageViewedState = eMessageViewedStateReplied; 
    
    [[NSUserDefaults standardUserDefaults]setValue:@(YES) forKey:@"MESSAGE_SENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [self.navigationController popToRootViewControllerAnimated:YES];
    [CWPushNotificationsAPI registerForPushNotifications];
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
            
            if (self.incomingMessage) {
                [CWAnalytics event:@"MESSAGE_SENT" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }
            else {
                [CWAnalytics event:@"MESSAGE_SENT" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            
            [self didSendMessage];
            break;
            
        case MessageComposeResultCancelled:
            if (self.incomingMessage) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }
            else {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            
            [self.player replayVideo];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.messageComposer = nil;
}
@end
