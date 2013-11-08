//
//  OpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "OpenerViewController.h"
#import "VideoPlayerViewController.h"
#import "SenderViewController.h"
#import "AVCamCaptureManager.h"
#import "PlaybackViewController.h"
#import "AssetItem.h"
#import "CWMessageItem.h"


@interface OpenerViewController () <VideoPlayerViewDelegate,AVCamCaptureManagerDelegate>
{
    CGRect smallFrame;
    NSInteger tickCount;
    NSTimeInterval startRecordTime;
    BOOL autoPush;
}
// player objects
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,strong) VideoPlayerViewController * videoPlayerVC;
@property (nonatomic,strong) NSTimer * recordTimer;
@property (nonatomic,strong) NSTimer * reactionTimer;
@property (nonatomic,strong) NSTimer * startRecordTimer;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation OpenerViewController

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
    [self setupCaptureManager];
    [super viewDidLoad];
    
    smallFrame = self.cameraView.frame;
	// Do any additional setup after loading the view.
    self.videoPlayerVC = [[VideoPlayerViewController alloc]init];
    [self.videoPlayerVC setLoops:NO];
    [self.videoPlayerVC setDelegate:self];
    [self.videoPlayerVC.view setFrame:self.playbackView.bounds];
    [self.playbackView addSubview:self.videoPlayerVC.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.cameraView setFrame:smallFrame];
    [self.captureVideoPreviewLayer setFrame:self.cameraView.bounds];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoPlayerVC setURL:self.videoURL];
    [self.videoPlayerVC replay];
    autoPush = YES;
    tickCount = startRecordTime;
    [self.timeLabel setTextColor:[UIColor whiteColor]];
    [self.timeLabel setText:[NSString stringWithFormat:@"Reply in 0:%02d",tickCount]];
    self.startRecordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRecordingWithTimer:) userInfo:nil repeats:YES];
 
}

- (void)startRecordingWithTimer:(NSTimer*)timer
{
    [self.timeLabel setText:[NSString stringWithFormat:@"Reply in 0:%02d",tickCount]];
    [self.timeLabel setTextColor:[UIColor whiteColor]];
    tickCount--;
    if(tickCount <= 0)
    {
        tickCount = self.videoPlayerVC.videoLength - startRecordTime;
        [self.timeLabel setTextColor:[UIColor redColor]];
        [self.timeLabel setText:[NSString stringWithFormat:@"Recording Reaction 0:%02d",tickCount]];
        self.reactionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onReactionTick:) userInfo:nil repeats:YES];
        NSAssert([timer isEqual:self.startRecordTimer], @"expecting timer to equal startRecordingTimer");
        [self.startRecordTimer invalidate];
        self.startRecordTimer = nil;
        [self startRecording];
    }
}


- (void)setupCaptureManager
{
    if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
		
		[[self captureManager] setDelegate:self];
        
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self cameraView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
            
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            
            
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
		}
	}
    
}


- (void)startRecording
{
    [[self captureManager] startRecording];
}

- (void)stopRecording
{
    [[self captureManager] stopRecording];
    [self.recordTimer invalidate];
}

- (void)interruptRecording
{
    autoPush = NO;
    [self stopRecording];
}

- (void)resumeRecording
{
    autoPush = YES;
    [self startRecording];
}

- (void)setZipURL:(NSURL *)zipURL
{
    _zipURL = zipURL;
    
    CWMessageItem * messageItem = [[CWMessageItem alloc]init];
    [messageItem setZipURL:self.zipURL];
    [messageItem extractZip];
    startRecordTime = messageItem.metadata.startRecording;
    
    [self setVideoURL:messageItem.videoURL];
    
}




- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopRecording];
}

- (void)resetTimerAndStart:(BOOL)startTimer
{
    tickCount = MAX_RECORD_TIME;
    [self.timeLabel setTextColor:[UIColor redColor]];
    [self.timeLabel setText:[NSString stringWithFormat:@"Recording 0:%02d",tickCount]];
    
    if (startTimer) {
        [self.reactionTimer invalidate];
        self.reactionTimer = nil;
        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    }
}

- (void)onReactionTick:(NSTimer*)timer
{
    tickCount--;
    [self.timeLabel setTextColor:[UIColor redColor]];
    [self.timeLabel setText:[NSString stringWithFormat:@"Recording Reaction 0:%02d",tickCount]];
}

- (void)onTick:(NSTimer*)timer
{
    tickCount--;
    if (tickCount <= 0) {
        [self stopRecording];
        tickCount = 0;
    }
    [self.timeLabel setTextColor:[UIColor redColor]];
    [self.timeLabel setText:[NSString stringWithFormat:@"Recording 0:%02d",tickCount]];
    
}



- (void) captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager withVideoURL:(NSURL*)videoURL
{
    if (autoPush) {
        PlaybackViewController * playbackVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playbackVC"];
        [playbackVC setStartRecordingTime:startRecordTime];
        [playbackVC setVideoURL:videoURL];
        [self.navigationController pushViewController:playbackVC animated:YES];
        
    }
}


- (void)videoPlayerViewControllerDidFinishPlayback
{
    // swap videos
    [UIView animateWithDuration:0.6 animations:^{
        [self.cameraView setFrame:self.view.bounds];
    }];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.6];
    [self.captureVideoPreviewLayer setFrame:self.view.bounds];
    [CATransaction commit];
    [self resetTimerAndStart:YES];

}

@end
