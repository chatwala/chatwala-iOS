//
//  CWOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWOpenerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWVideoManager.h"
#import "CWMessageItem.h"


@interface CWOpenerViewController () <CWVideoPlayerDelegate,CWVideoRecorderDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSTimeInterval startRecordTime;
}
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) CWMessageItem * messageItem;

@property (nonatomic,strong) NSTimer * reviewCountdownTimer;    // watching thier reaction to what you said
@property (nonatomic,strong) NSTimer * reactionCountdownTimer;  // reacting to what they said
@property (nonatomic,strong) NSTimer * responseCountdownTimer;  // your response



@property (nonatomic,assign) NSInteger responseCountdownTickCount;
- (void)onResponseCountdownTick:(NSTimer*)timer;

//@property (nonatomic,strong) NSTimer * reactionTimer;
//@property (nonatomic,strong) NSTimer * startRecordTimer;

@end

@implementation CWOpenerViewController
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
    self.feedbackVC = [[CWFeedbackViewController alloc]init];
    [self addChildViewController:self.feedbackVC];
    [self.view addSubview:self.feedbackVC.view];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.player = [[CWVideoManager sharedManager]player];
    self.recorder = [[CWVideoManager sharedManager]recorder];
    
    
    [self.player setDelegate:self];
    [self.recorder setDelegate:self];
    
    
    
    NSAssert(self.messageItem, @"message item must be non-nil");
    
    [self.player setVideoURL:self.messageItem.videoURL];
    
    [self setupCameraView];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupCameraView
{
    [self.recorder.recorderView setFrame:self.cameraView.bounds];
    [self.cameraView addSubview:self.recorder.recorderView];
}


- (void)setZipURL:(NSURL *)zipURL
{
    _zipURL = zipURL;
    self.messageItem = [[CWMessageItem alloc]init];
    [self.messageItem setZipURL:self.zipURL];
    [self.messageItem extractZip];
    startRecordTime = self.messageItem.metadata.startRecording;
    
}



- (void)onResponseCountdownTick:(NSTimer*)timer
{
    self.responseCountdownTickCount--;
    
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,self.responseCountdownTickCount]];
}




#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer
{
    [self.playbackView addSubview:player.playbackView];
    [player.playbackView setFrame:self.playbackView.bounds];
    [player playVideo];
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    self.responseCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onResponseCountdownTick:) userInfo:nil repeats:YES];
    self.responseCountdownTickCount = MAX_RECORD_TIME;
    
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,self.responseCountdownTickCount]];
    
}


#pragma mark CWVideoRecorderDelegate

- (void)recorder:(CWVideoRecorder*)recorder didFailWithError:(NSError *)error
{
    
}

- (void)recorderRecordingBegan:(CWVideoRecorder *)recorder
{
    
}

- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    
}


@end
