//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWReviewViewController.h"
#import "CWVideoManager.h"

@interface CWReviewViewController () <CWVideoPlayerDelegate>
{
    CWVideoPlayer * player;
}
@end

@implementation CWReviewViewController

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
    
    player =[[CWVideoManager sharedManager]player];
    CWVideoRecorder * recorder = [[CWVideoManager sharedManager]recorder];
    [player setDelegate:self];
    [player setVideoURL:recorder.tempFileURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSURL*)cacheDirectoryURL
{
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}

- (IBAction)onRecordAgain:(id)sender {
}

- (IBAction)onSend:(id)sender {
}


#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer
{
    [self.previewView addSubview:player.playbackView];
    [player.playbackView setFrame:self.previewView.bounds];
    [player play];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    [player replay];
}

@end
