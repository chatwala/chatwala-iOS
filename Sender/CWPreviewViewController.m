//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 Chatwala. All rights reserved.
//

#import "CWPreviewViewController.h"
#import "CWVideoManager.h"
#import "AppDelegate.h"
#import "CWGroundControlManager.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import "Message.h"
#import "CWPushNotificationsAPI.h"
#import "CWDataManager.h"
#import "CWAnalytics.h"
#import "CWUserDefaultsController.h"
#import "CWMessageSender.h"

@interface CWPreviewViewController () <CWVideoPlayerDelegate,CWMessageSenderDelegate>//,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSInteger playbackCount;
    
}
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) MFMailComposeViewController *mailComposer;
@property (nonatomic,strong) MFMessageComposeViewController *messageComposer;

@property (nonatomic,strong) CWMessageSender *messageSender;

@end

@implementation CWPreviewViewController

@synthesize player;
@synthesize recorder;

- (void)viewDidLoad {
    
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

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    if ([player.delegate isEqual:self])
    {
        [player cleanUp];
        player.delegate = nil;
        player = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (![CWUserDefaultsController shouldShowMessagePreview]) {
        [self sendMessageFromUser:[[CWUserManager sharedInstance] localUserID]];
        return;
    }
    else {
        [self setupVideoPreview];
    }
}

- (void)goToBackground {
    
    [self.messageSender cancel];
}

// TODO: Poorly named - this is the 'X' button firing when user is discarding their message.
- (void)onTap:(id)sender {
    
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    [self.messageSender cancel];
    [[CWMessageManager sharedInstance] clearUploadURLForOriginalMessage];
    
    //TODO: Cancel message send
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
    
    [self sendMessageFromUser:[[CWUserManager sharedInstance] localUserID]];
}

- (void)sendMessageFromUser:(NSString *)userID {
    
    [self.player setDelegate:nil];
    [self.player stop];
    [self.sendButton setButtonState:eButtonStateBusy];
    
    Message * message = [[CWDataManager sharedInstance] createMessageWithSender:userID inResponseToIncomingMessage:self.incomingMessage];
    
    message.chatwalaZipURL = [NSURL fileURLWithPath:[[CWVideoFileCache sharedCache] outboxDirectoryPathForKey:message.messageID]];
    message.startRecording = [NSNumber numberWithDouble:self.startRecordingTime];
    
    self.messageSender = [[CWMessageSender alloc] init];
    self.messageSender.delegate = self;
    self.messageSender.messageBeingSent = message;
    self.messageSender.messageBeingRespondedTo = self.incomingMessage;
    
    [self.messageSender sendMessageFromUser:userID];
}

- (void)setupVideoPreview {
    [self.sendButton setButtonState:eButtonStateShare];
    playbackCount = 0;
    [player setDelegate:self];
    [player setVideoURL:recorder.tempFileURL];
}

#pragma mark - Notification handlers

- (void)appHasGoneInBackground:(NSNotification*)notification
{
    [self.messageSender cancel];
}

#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer {
    [self showVideoPreview];
}

- (void)showVideoPreview {
    
    [self.previewView addSubview:player.playbackView];
    self.previewView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5);
    player.playbackView.frame = self.previewView.bounds;
    
    
    [player playVideo];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer {
    
    playbackCount++;
    [player replayVideo];
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error {
    
}

#pragma mark - CWMessageSenderDelegate methods

- (void)messageSender:(CWMessageSender *)messageSender shouldPresentMessageComposerController:(UINavigationController *)composerNavController {
    [self.player setDelegate:nil];
    [self.player stop];
    [self presentViewController:composerNavController animated:YES completion:nil];
}

- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender forMessage:(Message *)sentMessage {

    [self.player setVideoURL:self.recorder.tempFileURL];
    [self.player createProfilePictureThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
        
        if (thumbnail) {
            
            // Uploading as a profile picture & thumbnail image
            if (![[CWUserManager sharedInstance] hasUploadedProfilePicture:sentMessage.senderID]) {

                [[CWUserManager sharedInstance] uploadProfilePicture:thumbnail forUser:[[CWUserManager sharedInstance] localUserID] completion:nil];
            }
            
            [sentMessage uploadThumbnailImage:thumbnail];
        }
    }];
    
    [self.player stop];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error {
    // TODO: Show error
    
}

@end