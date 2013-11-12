//
//  CWComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWComposerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWVideoManager.h"

@interface CWComposerViewController () <CWVideoRecorderDelegate>
{
    NSInteger tickCount;
}
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) NSTimer * recordTimer;
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


- (void)onTick:(NSTimer*)timer
{
    
    tickCount--;
    if (tickCount <= 0) {
        [self stopRecording];
        tickCount = 0;
    }
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:@"Recording 0:%02d",tickCount]];
}

- (void)startRecording
{
    [self.feedbackVC.feedbackLabel setText:@""];
    [[[CWVideoManager sharedManager]recorder] startRecording];
}

- (void)stopRecording
{
    [[[CWVideoManager sharedManager]recorder]stopRecording];
    [self.recordTimer invalidate];
    self.recordTimer = nil;
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
    tickCount = MAX_RECORD_TIME;
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:@"Recording 0:%02d",tickCount]];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];

}


- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    
}

@end
