//
//  CWSSComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 Chatwala. All rights reserved.
//

#import "CWSSComposerViewController.h"
#import "CWSSReviewViewController.h"
#import "CWUserDefaultsController.h"
#import "CWMessageSender.h"
#import "CWDataManager.h"
#import "CWUserManager.h"
#import "Message.h"

@interface CWSSComposerViewController () <CWMessageSenderDelegate>

@property (nonatomic) CWMessageSender *messageSender;
@property (nonatomic) NSTimer *countdownTimer;
@property (nonatomic,assign) NSInteger countdownCount;

@end

@implementation CWSSComposerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[[CWVideoManager sharedManager]recorder]setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager]recorder]recorderView] belowSubview:self.middleButton];
    [[[[CWVideoManager sharedManager]recorder]recorderView]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.5f)];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    self.countdownCount = 10;
    [self.recordMessageLabel setText:[NSString stringWithFormat:@"Recording...%ld",(long)self.countdownCount]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;

    [super viewWillDisappear:animated];
}

- (void)updateLabel {
    
    self.countdownCount--;
    
    if (self.countdownCount == 0) {
        [self.countdownTimer invalidate];
        [self.recordMessageLabel setText:@"Sending..."];
    }
    else {
        [self.recordMessageLabel setText:[NSString stringWithFormat:@"Recording...%ld",(long)self.countdownCount]];
    }
}

- (void)showPreview {

    if ([CWUserDefaultsController shouldShowMessagePreview]) {
        CWSSReviewViewController * previewVC = [[CWSSReviewViewController alloc]init];
        [previewVC setStartRecordingTime:0];
        [self.navigationController pushViewController:previewVC animated:NO];
    }
    else {

        NSString *localUserID = [[CWUserManager sharedInstance] localUserID];
        
        Message * message = [[CWDataManager sharedInstance] createMessageWithSender:localUserID inResponseToIncomingMessage:nil];
        
        message.videoURL = [[CWVideoManager sharedManager]recorder].outputFileURL;
        message.zipURL = [NSURL fileURLWithPath:[[CWDataManager cacheDirectoryPath]stringByAppendingPathComponent:MESSAGE_FILENAME]];
        message.startRecording = [NSNumber numberWithDouble:0.0];
        message.recipientID = self.recipientID;
        
        self.messageSender = [[CWMessageSender alloc] init];
        self.messageSender.delegate = self;
        self.messageSender.messageBeingSent = message;
        
        self.hasSentMessage = YES;
        [self.messageSender sendMessageFromUser:localUserID];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesEnded:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    BOOL wasButton = CGRectContainsPoint(self.middleButton.frame, [touch locationInView:self.view]);

    // get duration
    
    if (wasButton) {
        [CWAnalytics event:@"COMPLETE_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    }else{
        [CWAnalytics event:@"COMPLETE_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    }
}

#pragma mark - CWMessageSenderDelegate methods

- (void)messageSender:(CWMessageSender *)messageSender shouldPresentMessageComposerController:(UINavigationController *)composerNavController {
    [self presentViewController:composerNavController animated:YES completion:nil];
}

- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender forMessage:(Message *)sentMessage {
    
    CWVideoPlayer *player = [[CWVideoManager sharedManager] player];
    
    [player setVideoURL:[[CWVideoManager sharedManager]recorder].tempFileURL];
    [player createProfilePictureThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
        
        if (thumbnail) {
            
            // Uploading as a profile picture & thumbnail image
            if (![[CWUserManager sharedInstance] hasUploadedProfilePicture:sentMessage.senderID]) {

                [[CWUserManager sharedInstance] uploadProfilePicture:thumbnail forUser:[[CWUserManager sharedInstance] localUserID] completion:nil];
            }
            
            [sentMessage uploadThumbnailImage:thumbnail];
        }
    }];

    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error {
    // TODO: Show error
    [self.navigationController popViewControllerAnimated:YES];
}

@end
