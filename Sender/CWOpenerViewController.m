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

@interface CWOpenerViewController () <CWVideoPlayerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSTimeInterval startRecordTime;
}
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) CWMessageItem * messageItem;
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
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.player = [[CWVideoManager sharedManager]player];
    [self.player setDelegate:self];
    [self.player setVideoURL:self.messageItem.videoURL];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)setZipURL:(NSURL *)zipURL
{
    _zipURL = zipURL;
    
    self.messageItem = [[CWMessageItem alloc]init];
    [self.messageItem setZipURL:self.zipURL];
    [self.messageItem extractZip];
    startRecordTime = self.messageItem.metadata.startRecording;
    
//    [self setVideoURL:messageItem.videoURL];
    
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
    
}



@end
