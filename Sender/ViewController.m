//
//  ViewController.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "ViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "PlaybackViewController.h"

@interface ViewController ()<AVCamCaptureManagerDelegate>
{
    NSInteger tickCount;
}
@property (nonatomic,strong) NSTimer * recordTimer;
@property (nonatomic,strong) MPMoviePlayerViewController * moviePlayer;
@property (nonatomic,strong) AVPlayerItem * playerItem;
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [self setupCaptureManager];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.playbackView.layer setBorderColor:[[UIColor redColor] CGColor]];
    [self.playbackView.layer setBorderWidth:10];
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startRecording];
}

- (void)startRecording
{
    tickCount = MAX_RECORD_TIME;
    
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    [[self captureManager] startRecording];
}

- (void)stopRecording
{
    [[self captureManager] stopRecording];
    [self.recordTimer invalidate];
    [self.captureManager stopRecording];
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
			UIView *view = [self videoPreviewView];
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
            
            
			/*
			
            // Create the focus mode UI overlay
			UILabel *newFocusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, viewLayer.bounds.size.width - 20, 20)];
			[newFocusModeLabel setBackgroundColor:[UIColor clearColor]];
			[newFocusModeLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50]];
			AVCaptureFocusMode initialFocusMode = [[[captureManager videoInput] device] focusMode];
			[newFocusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:initialFocusMode]]];
			[view addSubview:newFocusModeLabel];
			[self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
			[self setFocusModeLabel:newFocusModeLabel];
            [newFocusModeLabel release];
            
            // Add a single tap gesture to focus on the point tapped, then lock focus
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
			[singleTap setDelegate:self];
			[singleTap setNumberOfTapsRequired:1];
			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
			[doubleTap setDelegate:self];
			[doubleTap setNumberOfTapsRequired:2];
			[singleTap requireGestureRecognizerToFail:doubleTap];
			[view addGestureRecognizer:doubleTap];
			
			[doubleTap release];
			[singleTap release];
             */
		}
	}
    
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self stopRecording];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
     AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    NSLog(@"status: %d",status);
    
    if (status == AVPlayerStatusReadyToPlay) {
        [self.player play];
    }
    
}


- (void) captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager withVideoURL:(NSURL*)videoURL
{
    PlaybackViewController * playbackVC = [self.storyboard instantiateViewControllerWithIdentifier:@"playbackVC"];
    
    [playbackVC setVideoURL:videoURL];
    [self.navigationController pushViewController:playbackVC animated:YES];
    
}

@end
