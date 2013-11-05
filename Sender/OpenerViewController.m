//
//  OpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "OpenerViewController.h"
#import "VideoPlayerViewController.h"
#import "ViewController.h"

@interface OpenerViewController () <VideoPlayerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *playbackView;
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
    [super viewDidLoad];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)videoPlayerViewControllerDidFinishPlayback
{
    ViewController * recorderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"recorderVC"];
    
    [self.navigationController pushViewController:recorderVC animated:YES];
}

@end
