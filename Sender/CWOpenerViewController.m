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
#import "CWGroundControlManager.h"


@interface CWOpenerViewController () <CWVideoPlayerDelegate,CWVideoRecorderDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSTimeInterval startRecordTime;
    CGRect smallFrame;
    CGRect largeFrame;
}

@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;


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
@synthesize startRecordTime;

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

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    if(CGRectIsEmpty(smallFrame))
//    {
//        smallFrame = self.cameraView.frame;
//    }
//    if(CGRectIsEmpty(largeFrame))
//    {
//        largeFrame = self.playbackView.frame;
//    }
//       
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.player = [[CWVideoManager sharedManager]player];
    self.recorder = [[CWVideoManager sharedManager]recorder];
    
    
    [self.player setDelegate:self];
    [self.recorder setDelegate:self];
    
    
//    if(!CGRectIsEmpty(smallFrame))
//    {
//        self.cameraView.frame = smallFrame;
//    }
//    if(!CGRectIsEmpty(largeFrame))
//    {
//        self.playbackView.frame = largeFrame;
//    }
    
    NSAssert(self.messageItem, @"message item must be non-nil");
    
    [self.player setVideoURL:self.messageItem.videoURL];
    
    [self setupCameraView];
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    switch (self.openerState) {
        case CWOpenerPreview:
            [self setOpenerState:CWOpenerReview];
            break;
        case CWOpenerReview:
            break;
            
        case CWOpenerReact:
            break;
            
        case CWOpenerRespond:
            [self.recorder stopVideoRecording];
            break;
            
        default:
            break;
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setOpenerState:(CWOpenerState)openerState
{
    _openerState = openerState;
    
    
    
    switch (self.openerState) {
        case CWOpenerPreview:
            /*
             Preview State: Video Message is ready
             • update view and feedback to reflect Preview state ( in subclass )
             */
            [self.feedbackVC.feedbackLabel setText:[[CWGroundControlManager sharedInstance] tapToPlayVideo]];
            break;
            
            
            
            
        case CWOpenerReview:
            /*
            
             Review State: Video Message is playing, but not Recording
             • check if startRecording value is zero
                • if zero change state to React
                • else start Review count down
             • play Video Message
             • update view and feedback to reflect Review state ( in subclass )
             */
            if (self.messageItem.metadata.startRecording == 0) {
                [self setOpenerState:CWOpenerReact];
            }else{
                [self startReviewCountDown];
            }
            [self.player playVideo];
            break;
            
            
            
            
        case CWOpenerReact:
            /*
             
             Reaction State: Playing Message and Recording Reaction
             • start recording Reaction portion of video
             • update view and feedback to reflect Reaction state ( in subclass )
             
             */
            [self startReactionCountDown];
            break;
            
            
            
            
        case CWOpenerRespond:
            /*
             
             Responding State: Video Message ended and Recording Continues ( Response portion of the video )
             • start recording Reaction portion of video
             • update view and feedback to reflect Responding state ( in subclass )
             
             */
            [self startResponseCountDown];
            break;
    }
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


- (void)killTimers
{
    if (self.reviewCountdownTimer) {
        [self.reviewCountdownTimer invalidate];
        self.reviewCountdownTimer = nil;
    }
    
    if (self.reactionCountdownTimer) {
        [self.reactionCountdownTimer invalidate];
        self.reactionCountdownTimer = nil;
    }
    
    if (self.responseCountdownTimer) {
        [self.responseCountdownTimer invalidate];
        self.responseCountdownTimer = nil;
    }
}


- (void)startReviewCountDown
{
    [self killTimers];
    self.reviewCountdownTickCount = self.messageItem.metadata.startRecording;
    self.reviewCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onReviewCountdownTick:) userInfo:nil repeats:YES];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackReviewString],self.reviewCountdownTickCount]];
    NSLog(@"started review countdown from %d",self.reviewCountdownTickCount);
    
}

- (void)startReactionCountDown
{
    [self killTimers];
    [self.recorder startVideoRecording];
    self.reactionCountdownTickCount = 0;
    self.reactionCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onReactionCountdownTick:) userInfo:nil repeats:YES];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackReactionString],self.reactionCountdownTickCount]];
    NSLog(@"started reaction countdown from %d",self.reactionCountdownTickCount);
}

- (void)startResponseCountDown
{
    [self killTimers];
    self.responseCountdownTickCount = MAX_RECORD_TIME;
    self.responseCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onResponseCountdownTick:) userInfo:nil repeats:YES];
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackResponseString],self.responseCountdownTickCount]];
    NSLog(@"started response countdown from %d",self.responseCountdownTickCount);
}


- (void)onReviewCountdownTick:(NSTimer*)timer
{
    self.reviewCountdownTickCount--;
    if (self.reviewCountdownTickCount <=0 ) {
        [self.reviewCountdownTimer invalidate];
        self.reviewCountdownTimer = nil;
        
        // start reaction state
        [self setOpenerState:CWOpenerReact];
        
    }
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackReviewString],self.reviewCountdownTickCount]];
}

- (void)onReactionCountdownTick:(NSTimer*)timer
{
    self.reactionCountdownTickCount++;
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackReactionString],self.reactionCountdownTickCount]];
}


- (void)onResponseCountdownTick:(NSTimer*)timer
{
    self.responseCountdownTickCount--;
    if (self.responseCountdownTickCount <=0 ) {
        [self.responseCountdownTimer invalidate];
        self.responseCountdownTimer = nil;
        [self.recorder stopVideoRecording];
        
        
    }
    [self.feedbackVC.feedbackLabel setText:[NSString stringWithFormat:[[CWGroundControlManager sharedInstance] feedbackResponseString],self.responseCountdownTickCount]];
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
    [self setOpenerState:CWOpenerRespond];
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
    [reviewVC setIncomingMessageItem:self.messageItem];
    [self.navigationController pushViewController:reviewVC animated:NO];

}


@end
