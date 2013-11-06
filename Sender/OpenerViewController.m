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

@interface OpenerViewController () <VideoPlayerViewDelegate,AVCamCaptureManagerDelegate>
{
    CGRect smallFrame;
}
// player objects
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,strong) VideoPlayerViewController * videoPlayerVC;

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

- (void)setVideoURL:(NSURL *)videoURL
{

    NSURL * newURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), [videoURL lastPathComponent],@".mov"]];
    NSError * error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:videoURL toURL:newURL error:&error];
    if (error) {
        NSLog(@"%@",error.debugDescription);
    }
    _videoURL = newURL;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoPlayerVC setURL:self.videoURL];
    [self.captureManager startRecording];
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

- (void)videoPlayerViewControllerDidFinishPlayback
{
    // swap videos
    
}

@end
