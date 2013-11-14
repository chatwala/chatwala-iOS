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

@interface CWOpenerViewController () <CWVideoPlayerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
}
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
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
    self.player = [[CWVideoManager sharedManager]player];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self player]setDelegate:self];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
