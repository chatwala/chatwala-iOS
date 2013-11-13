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
    CWVideoRecorder * recorder;
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
    NSLog(@"%s",__FUNCTION__);
    
    player =[[CWVideoManager sharedManager]player];
    recorder = [[CWVideoManager sharedManager]recorder];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s",__FUNCTION__);
    
    [player setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%s",__FUNCTION__);
    
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
    NSLog(@"%s",__FUNCTION__);
    
    [self.previewView addSubview:player.playbackView];
    [player.playbackView setFrame:self.previewView.bounds];
    [player play];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    [player replay];
}

@end
