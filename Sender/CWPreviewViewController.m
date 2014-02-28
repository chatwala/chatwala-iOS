//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWPreviewViewController.h"
#import "CWVideoManager.h"
#import "CWFlowManager.h"
#import "AppDelegate.h"
#import "CWLandingViewController.h"
#import "CWGroundControlManager.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import "CWUtility.h"
#import "Message.h"
#import "Thread.h"
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
        [self sendMessageFromUser:[[CWUserManager sharedInstance] localUser]];
        return;
    }
    else {
        [self setupVideoPreview];
    }
}

- (void)goToBackground {

    [self.messageSender cancel];
//    if (self.mailComposer) {
//        [[self mailComposer]dismissViewControllerAnimated:NO completion:nil];
//    }
}

// TODO: Poorly named - this is the 'X' button firing when user is discarding their message.
- (void)onTap:(id)sender {
    
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    [self.messageSender cancel];
    
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
    
    [self sendMessageFromUser:[[CWUserManager sharedInstance] localUser]];
}

- (void)sendMessageFromUser:(User *)localUser {
    
    [player stop];
    [self.sendButton setButtonState:eButtonStateBusy];
    
    Message * message = [[CWDataManager sharedInstance] createMessageWithSender:localUser inResponseToIncomingMessage:self.incomingMessage];
    
    message.videoURL = recorder.outputFileURL;
    message.zipURL = [NSURL fileURLWithPath:[[CWDataManager cacheDirectoryPath]stringByAppendingPathComponent:MESSAGE_FILENAME]];
    message.startRecording = [NSNumber numberWithDouble:self.startRecordingTime];

    self.messageSender = [[CWMessageSender alloc] init];
    self.messageSender.delegate = self;
    self.messageSender.messageBeingSent = message;
    self.messageSender.messageBeingRespondedTo = self.incomingMessage;
    
    [self.messageSender sendMessageFromUser:localUser];
}

- (void)uploadProfilePictureForUser:(User *) user {
    
    if([[CWUserManager sharedInstance] hasUploadedProfilePicture:user]) {
        return;//already did this
    }
    
    [self.player createProfilePictureThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
        [[CWUserManager sharedInstance] uploadProfilePicture:thumbnail forUser:user completion:nil];
    }];
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
    [self presentViewController:composerNavController animated:YES completion:nil];
}

- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender {
    [self uploadProfilePictureForUser:[[CWUserManager sharedInstance] localUser]];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error {
    // TODO: Show error

}

@end