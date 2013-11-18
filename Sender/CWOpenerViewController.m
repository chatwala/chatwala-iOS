//
//  CWOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWOpenerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWMessageItem.h"


@interface CWOpenerViewController () <CWVideoPlayerDelegate,CWVideoRecorderDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSTimeInterval startRecordTime;
    CGRect smallFrame;
    CGRect largeFrame;
}
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) CWMessageItem * messageItem;

@property (nonatomic,strong) NSTimer * reviewCountdownTimer;    // watching thier reaction to what you said
@property (nonatomic,strong) NSTimer * reactionCountdownTimer;  // reacting to what they said
@property (nonatomic,strong) NSTimer * responseCountdownTimer;  // your response



@property (nonatomic,assign) NSInteger reviewCountdownTickCount;
@property (nonatomic,assign) NSInteger reactionCountdownTickCount;
@property (nonatomic,assign) NSInteger responseCountdownTickCount;

- (void)onResponseCountdownTick:(NSTimer*)timer;
- (void)onReactionCountdownTick:(NSTimer*)timer;
- (void)onReviewCountdownTick:(NSTimer*)timer;
- (void)startResponseCountDown;
- (void)startReviewCountDown;
- (void)startReactionCountDown;
- (void)setupCameraView;

@end

@implementation CWOpenerViewController
@synthesize player;
@synthesize recorder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        smallFrame = CGRectZero;
        largeFrame = CGRectZero;
    }
    return self;
}

- (void)dealloc
{
    [self.player setDelegate:nil];
    [self.recorder setDelegate:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.feedbackVC = [[CWFeedbackViewController alloc]init];
    [self addChildViewController:self.feedbackVC];
    [self.view addSubview:self.feedbackVC.view];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(CGRectIsEmpty(smallFrame))
    {
        smallFrame = self.cameraView.frame;
    }
    if(CGRectIsEmpty(largeFrame))
    {
        largeFrame = self.playbackView.frame;
    }
       
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.player = [[CWVideoManager sharedManager]player];
    self.recorder = [[CWVideoManager sharedManager]recorder];
    
    
    [self.player setDelegate:self];
    [self.recorder setDelegate:self];
    
    
    if(!CGRectIsEmpty(smallFrame))
    {
        self.cameraView.frame = smallFrame;
    }
    if(!CGRectIsEmpty(largeFrame))
    {
        self.playbackView.frame = largeFrame;
    }
    
    NSAssert(self.messageItem, @"message item must be non-nil");
    
    [self.player setVideoURL:self.messageItem.videoURL];
    
    [self setupCameraView];
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    switch (self.openerState) {
        case CWOpenerPreview:
            // play preview
            [self.player playVideo];
            [self startReviewCountDown];
            [self setOpenerState:CWOpenerReview];
            break;
        case CWOpenerReview:
            //
            [self.cameraView setAlpha:0.5];
            break;
        case CWOpenerReact:
            //
            [self.cameraView setAlpha:1.0];
            break;
        case CWOpenerRespond:
            //
            [self.cameraView setAlpha:1.0];
            break;
    }
    
    [self.recorder stopVideoRecording];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//- (void)enteringCameraState:(CWOpenerState)state
//{
//    NSAssert(0, @"should be implemented in subclass");
//}

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
    if (self.responseCountdownTickCount <=0 ) {
        [self.responseCountdownTimer invalidate];
        self.responseCountdownTimer = nil;
        [self.recorder stopVideoRecording];
        
        
    }
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,self.responseCountdownTickCount]];
}
- (void)onReviewCountdownTick:(NSTimer*)timer
{
    self.reviewCountdownTickCount--;
    if (self.reviewCountdownTickCount <=0 ) {
        [self.reviewCountdownTimer invalidate];
        self.reviewCountdownTimer = nil;
        
        // start reaction timer
        [self startReactionCountDown];
        
    }
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_REVIEW_STRING,self.reviewCountdownTickCount]];
}

- (void)onReactionCountdownTick:(NSTimer*)timer
{
    self.reactionCountdownTickCount++;
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_REACTION_STRING,self.reactionCountdownTickCount]];
}

- (void)startResponseCountDown
{
    [self setOpenerState:CWOpenerRespond];
    self.responseCountdownTickCount = MAX_RECORD_TIME;
    self.responseCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onResponseCountdownTick:) userInfo:nil repeats:YES];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,self.responseCountdownTickCount]];
    NSLog(@"started response countdown from %d",self.responseCountdownTickCount);
}


- (void)startReviewCountDown
{
    self.reviewCountdownTickCount = self.messageItem.metadata.startRecording;
    self.reviewCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onReviewCountdownTick:) userInfo:nil repeats:YES];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_REVIEW_STRING,self.reviewCountdownTickCount]];
    NSLog(@"started review countdown from %d",self.reviewCountdownTickCount);
    
}

- (void)startReactionCountDown
{
    [self setOpenerState:CWOpenerReact];
    [self.recorder startVideoRecording];
    self.reactionCountdownTickCount = 0;
    self.reactionCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onReactionCountdownTick:) userInfo:nil repeats:YES];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:FEEDBACK_REACTION_STRING,self.reactionCountdownTickCount]];
    NSLog(@"started reaction countdown from %d",self.reactionCountdownTickCount);
}



#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer
{
    [self.playbackView addSubview:player.playbackView];
    [player.playbackView setFrame:self.playbackView.bounds];
    [self setOpenerState:CWOpenerPreview];
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    [UIView animateWithDuration:0.6 animations:^{
        [self.cameraView setFrame:largeFrame];
        [self.recorder.recorderView setFrame:self.cameraView.bounds];
    }];
    
    [self.reactionCountdownTimer invalidate];
    self.reactionCountdownTimer = nil;
    [self startResponseCountDown];
    
}


#pragma mark CWVideoRecorderDelegate

- (void)recorder:(CWVideoRecorder*)recorder didFailWithError:(NSError *)error
{
    
}

- (void)recorderRecordingBegan:(CWVideoRecorder *)recorder
{
    [self.feedbackVC.feedbackLabel setTextColor:[UIColor redColor]];
}

- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    [self.feedbackVC.feedbackLabel setTextColor:[UIColor whiteColor]];
    // push to review
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    [self.navigationController pushViewController:reviewVC animated:NO];

}


@end
