//
//  CWComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWComposerViewController.h"
#import "CWPreviewViewController.h"
#import "CWVideoManager.h"
#import "CWGroundControlManager.h"

@interface CWComposerViewController ()

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
    [self.middleButton.button addTarget:self action:@selector(onMiddleButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
//    self.middleButton = [[CWMiddleButton alloc]initWithFrame:CGRectMake(20, 20, 80, 80)];
//    [self.view addSubview:self.middleButton];
    [self setNavMode:NavModeNone];
    [self.navigationItem setHidesBackButton:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [[[[CWVideoManager sharedManager]recorder]recorderView]setFrame:self.view.bounds];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startRecording];
}


- (void)onMiddleButtonTap
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
}

- (void)startRecording
{
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

    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 / 30.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    self.startTime = [NSDate date];
}


- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    if (self.startTime == nil) {
        // push
        [self showPreview];
    }
}

- (void)showPreview
{
    NSAssert(0, @"should be over written in subclass");
}


@end
