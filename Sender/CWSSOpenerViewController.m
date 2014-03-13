//
//  CWSSOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSOpenerViewController.h"
#import "CWSSReviewViewController.h"
#import "CWVideoManager.h"
#import "CWGroundControlManager.h"
#import "CWMessageSender.h"
#import "CWUserDefaultsController.h"
#import "CWUserManager.h"
#import "CWDataManager.h"

@interface CWSSOpenerViewController () <CWMessageSenderDelegate,UIAlertViewDelegate>

@property (nonatomic) CWMessageSender *messageSender;
@property (nonatomic) NSTimer *countdownTimer;
@property (nonatomic,assign) NSInteger countdownCount;

@end

@implementation CWSSOpenerViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.openerMessageLabel setText:[[CWGroundControlManager sharedInstance] openerScreenMessage]];
    [self.recordMessageLabel setText:[[CWGroundControlManager sharedInstance] replyMessage]];
}

- (void)setOpenerState:(CWOpenerState)openerState
{
    [super setOpenerState:openerState];
    [self.playbackView setAlpha:1];
    [self.recordMessageLabel setAlpha:0];
    
    
    switch (self.openerState) {
        case CWOpenerPreview:
            [self.countdownTimer invalidate];
            [self.middleButton setButtonState:eButtonStatePlay];
            [self.cameraView setAlpha:0.5];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:1];
            }];
            
        }
            break;
            
            
        case CWOpenerReview:
            
            [self.countdownTimer invalidate];
            [self.middleButton setButtonState:eButtonStateStop];
            [self.cameraView setAlpha:0.5];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:0];
            }];
            
        }
            break;
        case CWOpenerReact:
            //
            [self.countdownTimer invalidate];
            [self.middleButton setButtonState:eButtonStateStop];
            [self.cameraView setAlpha:1.0];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:0];
            }];
            
        }
            break;
        case CWOpenerRespond:
            //
            [self.middleButton setButtonState:eButtonStateStop];
            [self.cameraView setAlpha:1.0];
        {
            
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
            self.countdownCount = 10;
            [self.recordMessageLabel setText:[NSString stringWithFormat:@"Recording your reply...%d",self.countdownCount]];
            [self.openerMessageLabel setAlpha:0.0f];
            [self.recordMessageLabel setAlpha:1.0f];
            
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.playbackView setAlpha:0.3f];
//                [self.recordMessageLabel setAlpha:1.0f];
            }];
        }
            break;
    }
}

- (void)updateLabel {

    self.countdownCount--;
    
    if (self.countdownCount == 0) {
        [self.recordMessageLabel setText:@"Sending..."];
        [self.countdownTimer invalidate];
    }
    else if (self.countdownCount < 5 && ![CWUserDefaultsController shouldShowMessagePreview]) {
        [self.recordMessageLabel setText:[NSString stringWithFormat:@"Sending reply in...%d",self.countdownCount]];
    }
    else {
        [self.recordMessageLabel setText:[NSString stringWithFormat:@"Recording your reply...%d",self.countdownCount]];
    }
}

- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder {

    [super recorderRecordingFinished:recorder];
    
    [self.countdownTimer invalidate];
    if(self.openerState == CWOpenerRespond) {
        
        if ([CWUserDefaultsController shouldShowMessagePreview]) {
            // push to review
            CWSSReviewViewController * reviewVC = [[CWSSReviewViewController alloc]init];
            [reviewVC setStartRecordingTime:[self.player videoLength] - self.activeMessage.startRecordingValue];
            
            [reviewVC setIncomingMessage:self.activeMessage];
            [self.navigationController pushViewController:reviewVC animated:NO];
        }
        else {
            
            if (self.shouldPromptBeforeSending) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Reply" message:@"Would you like to send this reply?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
                [alert show];
            }
            else {
                [self sendMessage];
            }
            
            self.shouldPromptBeforeSending = NO;
        }
    }
}

- (void)sendMessage {
    User *localUser = [[CWUserManager sharedInstance] localUser];
    Message *message = [[CWDataManager sharedInstance] createMessageWithSender:localUser inResponseToIncomingMessage:self.activeMessage];
    
    message.videoURL = [[CWVideoManager sharedManager]recorder].outputFileURL;
    message.zipURL = [NSURL fileURLWithPath:[[CWDataManager cacheDirectoryPath]stringByAppendingPathComponent:MESSAGE_FILENAME]];
    message.startRecording = [NSNumber numberWithDouble:[self.player videoLength] - self.activeMessage.startRecordingValue];
    
    self.messageSender = [[CWMessageSender alloc] init];
    self.messageSender.delegate = self;
    self.messageSender.messageBeingSent = message;
    self.messageSender.messageBeingRespondedTo = self.activeMessage;
    
    [self.messageSender sendMessageFromUser:localUser];
}

- (void)uploadProfilePictureForUser:(User *)user {
    
    if([[CWUserManager sharedInstance] hasUploadedProfilePicture:user]) {
        return;//already did this
    }

    // Setting the recorded video to the player, we should improve this so the player or the recorder can
    // take a screen capture [RK]
    
    [self.player setVideoURL:self.recorder.tempFileURL];
    [self.player createProfilePictureThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
    
        [[CWUserManager sharedInstance] uploadProfilePicture:thumbnail forUser:user completion:nil];
    }];
    
}

#pragma mark - CWMessageSenderDelegate methods

- (void)messageSender:(CWMessageSender *)messageSender shouldPresentMessageComposerController:(UINavigationController *)composerNavController {
    [self presentViewController:composerNavController animated:YES completion:nil];
}

- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender {
    [self uploadProfilePictureForUser:[[CWUserManager sharedInstance] localUser]];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - UIAlerViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.cancelButtonIndex == buttonIndex) {
        [self setOpenerState:CWOpenerPreview];
    }
    else {
        [self sendMessage];
    }
}

@end
