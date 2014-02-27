//
//  CWSSComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[[CWVideoManager sharedManager]recorder]setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view insertSubview:[[[CWVideoManager sharedManager]recorder]recorderView] belowSubview:self.middleButton];
    [[[[CWVideoManager sharedManager]recorder]recorderView]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5)];
}


- (void)showPreview {

    if ([CWUserDefaultsController shouldShowMessagePreview]) {
        CWSSReviewViewController * previewVC = [[CWSSReviewViewController alloc]init];
        [previewVC setStartRecordingTime:0];
        [self.navigationController pushViewController:previewVC animated:NO];
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
        self.messageSender.messageBeingRespondedTo = nil;
        
        [self.messageSender sendMessageFromUser:localUser];
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
