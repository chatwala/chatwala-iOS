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
    BOOL autoPush;
}
// player objects
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,strong) VideoPlayerViewController * videoPlayerVC;
@property (nonatomic,strong) NSTimer * recordTimer;
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
    [self startRecording];
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
    [self.timeLabel setHidden:YES];
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
    [self setVideoURL:messageItem.videoURL];
    
}




- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopRecording];
}

- (void)resetTimerAndStart:(BOOL)startTimer
{
    tickCount = MAX_RECORD_TIME;
    [self.timeLabel setText:[NSString stringWithFormat:@"%d",tickCount]];
    [self.timeLabel setHidden:NO];
    if (startTimer) {
        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    }
}

- (void)onTick:(NSTimer*)timer
{
    tickCount--;
    if (tickCount <= 0) {
        [self stopRecording];
        tickCount = 0;
    }
    [self.timeLabel setText:[NSString stringWithFormat:@"%d",tickCount]];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
//    NSLog(@"status: %d",status);
//    
//    if (status == AVPlayerStatusReadyToPlay) {
//        [self.player play];
//    }
//    
//}


- (void) captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager withVideoURL:(NSURL*)videoURL
{
    
    
    
    if (autoPush) {
        PlaybackViewController * playbackVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playbackVC"];
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
