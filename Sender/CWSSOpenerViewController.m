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

@interface CWSSOpenerViewController () <CWMessageSenderDelegate>

@property (nonatomic) CWMessageSender *messageSender;

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
        
            [self.middleButton setButtonState:eButtonStatePlay];
            [self.cameraView setAlpha:0.5];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:1];
            }];
            
        }
            break;
            
            
        case CWOpenerReview:
            //
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
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:0];
                [self.playbackView setAlpha:0.3];
                [self.recordMessageLabel setAlpha:1];
            }];
        }
            break;
    }
}

- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    [super recorderRecordingFinished:recorder];
    
    if(self.openerState == CWOpenerRespond)
    {
        if ([CWUserDefaultsController shouldShowMessagePreview]) {
            // push to review
            CWSSReviewViewController * reviewVC = [[CWSSReviewViewController alloc]init];
            [reviewVC setStartRecordingTime:[self.player videoLength] - self.activeMessage.startRecordingValue];
            
            [reviewVC setIncomingMessage:self.activeMessage];
            [self.navigationController pushViewController:reviewVC animated:NO];
        }
        else {
            // Let's send the message
            self.messageSender = [[CWMessageSender alloc] init];
            self.messageSender.delegate = self;
            
            User *localUser = [[CWUserManager sharedInstance] localUser];
            
            Message * message = [[CWDataManager sharedInstance] createMessageWithSender:localUser inResponseToIncomingMessage:nil];
            
            message.videoURL = [[CWVideoManager sharedManager]recorder].outputFileURL;
            message.zipURL = [NSURL fileURLWithPath:[[CWDataManager cacheDirectoryPath]stringByAppendingPathComponent:MESSAGE_FILENAME]];
            message.startRecording = [NSNumber numberWithDouble:0.0];
            
            self.messageSender = [[CWMessageSender alloc] init];
            self.messageSender.delegate = self;
            self.messageSender.messageBeingSent = message;
            self.messageSender.messageBeingRespondedTo = self.activeMessage;
            
            [self.messageSender sendMessageFromUser:localUser];
        }
        
    }
}

#pragma mark - CWMessageSenderDelegate methods

- (void)messageSender:(CWMessageSender *)messageSender shouldPresentMessageComposerController:(UINavigationController *)composerNavController {
    [self presentViewController:composerNavController animated:YES completion:nil];
}

- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender {
    //    [self uploadProfilePictureForUser:[[CWUserManager sharedInstance] localUser]];
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.messageSender = nil;
}

- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.messageSender = nil;
}

- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error {
    // TODO: Show error
    self.messageSender = nil;
}

@end
