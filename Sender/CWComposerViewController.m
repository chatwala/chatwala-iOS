//
//  CWComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWComposerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWGroundControlManager.h"

@interface CWComposerViewController ()
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) NSTimer * recordTimer;
//@property (nonatomic,assign) NSInteger tickCount;
@property (nonatomic, strong) NSDate * startTime;
@end

@implementation CWComposerViewController

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
    self.feedbackVC = [[CWFeedbackViewController alloc]initWithNibName:@"CWFeedbackViewController" bundle:[NSBundle mainBundle]];
    [self addChildViewController:self.feedbackVC];
    [self.view addSubview:self.feedbackVC.view];
    self.feedbackVC.view.frame = self.view.bounds;
    
//    self.middleButton = [[CWMiddleButton alloc]initWithFrame:CGRectMake(20, 20, 80, 80)];
//    [self.view addSubview:self.middleButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view insertSubview:[[[CWVideoManager sharedManager]recorder]recorderView] belowSubview:self.feedbackVC.view];
    [[[[CWVideoManager sharedManager]recorder]recorderView]setFrame:self.view.bounds];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startRecording];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopRecording];
}

- (void)onTick:(NSTimer*)timer
{
    NSTimeInterval tickCount = -[self.startTime timeIntervalSinceNow];
    if (tickCount >= MAX_RECORD_TIME) {
        [self stopRecording];
    }
    [self.middleButton setValue:tickCount];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackRecordingString], (int)tickCount]];
}

- (void)startRecording
{
    [self.feedbackVC.feedbackLabel setText:@""];
    [self.middleButton setButtonState:eButtonStateStop];
    [[[CWVideoManager sharedManager]recorder] startVideoRecording];
}

- (void)stopRecording
{
    [[[CWVideoManager sharedManager]recorder]stopVideoRecording];
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    self.startTime = nil;
}

#pragma mark CWVideoRecorderDelegate

- (void)recorder:(CWVideoRecorder *)recorder didFailWithError:(NSError *)error
{
    
}

- (void)recorderRecordingBegan:(CWVideoRecorder *)recorder
{
    // start record timer
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    [self.middleButton setMaxValue:MAX_RECORD_TIME];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackRecordingString],MAX_RECORD_TIME]];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 / 30.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    self.startTime = [NSDate date];
}


- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    if (self.startTime == nil) {
        // push
        [self showReview];
    }
}

- (void)showReview
{
    NSAssert(0, @"should be over written in subclass");
}


@end
