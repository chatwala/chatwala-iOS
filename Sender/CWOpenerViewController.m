//
//  CWOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWOpenerViewController.h"
#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWFlowManager.h"
#import "CWGroundControlManager.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"
#import "Message.h"
#import "CWAnalytics.h"

@interface CWOpenerViewController () 
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    CGRect smallFrame;
    CGRect largeFrame;
    
}

@property (nonatomic,strong) NSTimer * reviewCountdownTimer;    // watching thier reaction to what you said
@property (nonatomic,strong) NSTimer * reactionCountdownTimer;  // reacting to what they said
@property (nonatomic,strong) NSTimer * responseCountdownTimer;  // your response



@property (nonatomic,assign) NSInteger reviewCountdownTickCount;
//@property (nonatomic,assign) NSInteger reactionCountdownTickCount;
//@property (nonatomic,assign) NSInteger responseCountdownTickCount;
@property (nonatomic, strong) NSDate * startTime;


- (void)onResponseCountdownTick:(NSTimer*)timer;
- (void)onReactionCountdownTick:(NSTimer*)timer;
- (void)onReviewCountdownTick:(NSTimer*)timer;
- (void)startResponseCountDown;
- (void)startReviewCountDown;
- (void)startReactionCountDown;
- (void)setupCameraView;
- (void)onMiddleButtonTap;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self.navigationController setNavigationBarHidden:YES];
    [self setNavMode:NavModeNone];
    [self.navigationItem setHidesBackButton:YES];
    [self.middleButton.button addTarget:self action:@selector(onMiddleButtonTap) forControlEvents:UIControlEventTouchUpInside];
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.playbackView setAlpha:0];
    [self.cameraView setAlpha:0];
    
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
    NSAssert(self.activeMessage, @"expecting activeMessage to be set");
    
    NSAssert(self.activeMessage.videoURL, @"expecting video URL to be set");
    
    [self.player setVideoURL:self.activeMessage.videoURL];
    [self setupCameraView];
    
}

- (void)onMiddleButtonTap
{
    switch (self.openerState) {
        case CWOpenerPreview:
            self.activeMessage.eMessageViewedState = eMessageViewedStateRead;
            [self.activeMessage.managedObjectContext save:nil];
            [self setOpenerState:CWOpenerReview];
            break;
        case CWOpenerReview:
            [self setOpenerState:CWOpenerPreview];
            break;
        case CWOpenerReact:
            [self setOpenerState:CWOpenerPreview];
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

- (void) grabLastFrameOfVideo
{
    NSAssert(self.activeMessage, @"expecting active message to be set");
    NSAssert(self.player, @"expecting player to be set");
    if(!self.activeMessage.lastFrameImage)
    {
        [self.player createStillForLastFrameWithCompletionHandler:^(UIImage *thumbnail) {
            self.activeMessage.lastFrameImage = thumbnail;
        }];
    }
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
            self.startTime = nil;
            [self killTimers];
            [self.player stop];
            [self.recorder stopVideoRecording];
            [self.middleButton setMaxValue:MAX_RECORD_TIME];
            [self.middleButton setValue:0];
            [self setNavMode:NavModeBurger];
            [self grabLastFrameOfVideo];
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
            
            [CWAnalytics event:@"START_REVIEW" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            [self.player playVideo];
            
            [self.middleButton setMaxValue:MAX_RECORD_TIME];
            [self.middleButton setValue:0];
            
            if (self.activeMessage.startRecordingValue == 0) {
                [self setOpenerState:CWOpenerReact];
            }else{
                [self startReviewCountDown];
            }
            
            [self setNavMode:NavModeNone];
            break;
            
        case CWOpenerReact:
            /*
             
             Reaction State: Playing Message and Recording Reaction
             • start recording Reaction portion of video
             • update view and feedback to reflect Reaction state ( in subclass )
             
             */
            [CWAnalytics event:@"START_REACTION" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            [self startReactionCountDown];
            [self setNavMode:NavModeNone];
            break;
            
        case CWOpenerRespond:
            /*
             
             Responding State: Video Message ended and Recording Continues ( Response portion of the video )
             • start recording Reaction portion of video
             • update view and feedback to reflect Responding state ( in subclass )
             
             */
            [CWAnalytics event:@"START_REPLY" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            [self startResponseCountDown];
            [self setNavMode:NavModeNone];
            break;
    }
}

- (void)setupCameraView
{
    
    self.cameraView.frame = CGRectMake(0, 0, SCREEN_BOUNDS.size.width, SCREEN_BOUNDS.size.height*0.5);
    [self.recorder.recorderView setFrame:self.cameraView.bounds];
    [self.cameraView addSubview:self.recorder.recorderView];
    [UIView animateWithDuration:0.3 animations:^{
        [self.cameraView setAlpha:1];
    }];
}


- (void)setZipURL:(NSURL *)zipURL
{
    NSError * error = nil;
    
    self.activeMessage = [[CWDataManager sharedInstance] importMessageAtFilePath:zipURL withError:&error];
    [self.activeMessage setEMessageViewedState:eMessageViewedStateOpened];
    
    @try {
        [self.player setVideoURL:self.activeMessage.videoURL];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
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
    self.reviewCountdownTickCount = self.activeMessage.startRecordingValue;
    self.reviewCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onReviewCountdownTick:) userInfo:nil repeats:YES];
    NSLog(@"started review countdown from %d",self.reviewCountdownTickCount);
    
}

- (void)startReactionCountDown
{
    [self killTimers];
    [self.recorder startVideoRecording];
//    self.reactionCountdownTickCount = 0;
    self.reactionCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(onReactionCountdownTick:) userInfo:nil repeats:YES];
   
    
    NSTimeInterval reactionTime=self.player.videoLength - self.activeMessage.startRecordingValue;
    CGFloat startValue = reactionTime+MAX_RECORD_TIME;
    [self.middleButton setMaxValue:startValue];
    [self.middleButton setValue:0];
    self.startTime = [NSDate date];
    
}

- (void)startResponseCountDown
{
    [self killTimers];
//    self.responseCountdownTickCount = MAX_RECORD_TIME;
    self.responseCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(onResponseCountdownTick:) userInfo:nil repeats:YES];
//    NSLog(@"started response countdown from %d",self.responseCountdownTickCount);
}


- (void)onReviewCountdownTick:(NSTimer*)timer
{
    self.reviewCountdownTickCount--;
    if (self.reviewCountdownTickCount <=0 ) {
        [self.reviewCountdownTimer invalidate];
        self.reviewCountdownTimer = nil;
        
        // start reaction state
        [CWAnalytics event:@"COMPLETE_REVIEW" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(self.activeMessage.startRecordingValue)];
        [self setOpenerState:CWOpenerReact];
        
    }
}

- (void)onReactionCountdownTick:(NSTimer*)timer
{
    NSTimeInterval reactionTickCount = -[self.startTime timeIntervalSinceNow];
    [self.middleButton setValue:reactionTickCount];
//    NSLog(@"reaction count:%f", reactionTickCount);
}


- (void)onResponseCountdownTick:(NSTimer*)timer
{
    NSTimeInterval recordTickCount = -[self.startTime timeIntervalSinceNow];
    [self.middleButton setValue:recordTickCount];
    NSTimeInterval reactionTime=self.player.videoLength - self.activeMessage.startRecordingValue;
    
    CGFloat maxRecordTime = reactionTime+MAX_RECORD_TIME;

    if (recordTickCount >= maxRecordTime ) {
        [self.responseCountdownTimer invalidate];
        self.responseCountdownTimer = nil;
        [self.recorder stopVideoRecording];
        
        
    }
//    NSLog(@"reponse count:%f", recordTickCount);


}

#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer {
    
    [self.playbackView addSubview:player.playbackView];
//    self.playbackView.frame = CGRectMake(0, self.view.bounds.size.height*0.5, self.view.bounds.size.width, self.view.bounds.size.height*0.5);
    [player.playbackView setFrame:self.playbackView.bounds];
    [UIView animateWithDuration:0.3 animations:^{
        [self.playbackView setAlpha:1];
    }];
    
    [self setOpenerState:CWOpenerPreview];
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    [CWAnalytics event:@"COMPLETE_REACTION" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(self.player.videoLength - self.activeMessage.startRecordingValue)];

    [self setOpenerState:CWOpenerRespond];
}


#pragma mark CWVideoRecorderDelegate

- (void)recorder:(CWVideoRecorder*)recorder didFailWithError:(NSError *)error {
    
}

- (void)recorderRecordingBegan:(CWVideoRecorder *)recorder {
    
}

- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder {

    [self killTimers];
    if(self.openerState == CWOpenerRespond)
    {

        NSTimeInterval reactionTime=self.player.videoLength - self.activeMessage.startRecordingValue;
        [CWAnalytics event:@"COMPLETE_REPLY" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(self.recorder.videoLength - reactionTime)];
        
//        [self killTimers];
//        self.openerState = CWOpenerPreview;
    }
    else
    {
        //add some analytics for canceled stuff
        //stop and go back
        switch (self.openerState) {
            case CWOpenerReview:
                [CWAnalytics event:@"stop and go back" withCategory:@"Review" withLabel:@"" withValue:nil];
                break;
            case CWOpenerReact:
                [CWAnalytics event:@"stop and go back" withCategory:@"React" withLabel:@"" withValue:nil];
                break;
            default:
                break;
        }
    }

}

@end