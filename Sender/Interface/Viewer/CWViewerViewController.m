//
//  CWViewerViewController.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 5/6/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWViewerViewController.h"
#import "CWMiddleButton.h"
#import "CWVideoPlayer.h"
#import "Message.h"
#import "CWDataManager.h"

typedef NS_ENUM(NSUInteger, CWViewerState) {
    CWViewerStateStopped,
    CWViewerStatePlaying
};


@interface CWViewerViewController () <CWVideoPlayerDelegate>
@property (nonatomic) CWMiddleButton *middleButton;

@property (nonatomic) UIView *originalMessageView;
@property (nonatomic) UIView *incomingMessageView;

@property (nonatomic) CWVideoPlayer *originalMessagePlayer;
@property (nonatomic) CWVideoPlayer *incomingMessagePlayer;

@property (nonatomic) Message *originalMessage;

@property (nonatomic, assign) CWViewerState viewerState;

@end

@implementation CWViewerViewController

#pragma mark - ViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // Custom initialization
    self.middleButton = [[CWMiddleButton alloc] init];
    [self.middleButton setAutoresizesSubviews:YES];
    [self.middleButton setClearsContextBeforeDrawing:YES];
    [self.middleButton setOpaque:YES];
    [self.middleButton setBackgroundColor:[UIColor clearColor]];
    [self.middleButton setAlpha:1.0f];
    [self.view addSubview:self.middleButton];
    
    self.originalMessageView = [[UIView alloc] init];
    self.originalMessageView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.originalMessageView belowSubview:self.middleButton];
    
    self.incomingMessageView = [[UIView alloc] init];
    self.incomingMessageView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.incomingMessageView belowSubview:self.middleButton];
    
    [self setNavMode:NavModeBurger];
    [self.navigationItem setHidesBackButton:YES];
    [self.middleButton.button addTarget:self action:@selector(onMiddleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.originalMessageView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height / 2.0f);
    self.originalMessageView.frame = CGRectIntegral(self.originalMessageView.frame);
    [self.originalMessageView setAlpha:0.0f];
    
    self.incomingMessageView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.originalMessageView.frame), self.view.frame.size.width, self.view.frame.size.height - self.originalMessageView.frame.size.height);
    [self.incomingMessageView setAlpha:0.0f];

    self.middleButton.frame = CGRectMake(0.0f, 0.0f, 90.0f, 90.0f);
    
    [self.middleButton setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [self.middleButton setButtonState:eButtonStateStop];
    [self.middleButton setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.middleButton];
    
    [self configureVideoPlayers];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self stopVideoPlayback];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self cleanUpPlayers];
    [super viewDidDisappear:animated];
}

#pragma mark - Video Playback

- (void)configureVideoPlayers {
    self.originalMessagePlayer = [[CWVideoPlayer alloc] init];
    [self.originalMessagePlayer setVideoURL:self.originalMessage.videoURL];
    [self.originalMessagePlayer setDelegate:self];
    self.originalMessagePlayer.shouldMuteAudio = YES;
    
    self.incomingMessagePlayer = [[CWVideoPlayer alloc] init];
    [self.incomingMessagePlayer setVideoURL:self.incomingMessage.videoURL];
    [self.incomingMessagePlayer setDelegate:self];
}

- (void)startVideoPlayback {
    CMTime targetTime = CMTimeMakeWithSeconds([self.incomingMessage.startRecording doubleValue] , NSEC_PER_SEC);
    [self.originalMessagePlayer seekToTime:targetTime];
    
    self.viewerState = CWViewerStatePlaying;
    [self.middleButton setButtonState:eButtonStateStop];
    [self.originalMessagePlayer playVideo];
    [self.incomingMessagePlayer playVideo];
}

- (void)stopVideoPlayback {
    self.viewerState = CWViewerStateStopped;
    [self.middleButton setButtonState:eButtonStatePlay];
    [self.originalMessageView setAlpha:1.0f];
    [self.originalMessagePlayer stop];
    [self.incomingMessagePlayer stop];
}

- (void)cleanUpPlayers {
    [self.originalMessagePlayer cleanUp];
    [self.incomingMessagePlayer cleanUp];
    
    self.originalMessagePlayer = nil;
    self.incomingMessagePlayer = nil;
}

#pragma mark - User interaction

- (void)onMiddleButtonTapped:(id)sender {

    NSLog(@"Middle Button tapped!");
    
    switch (self.viewerState) {
        case CWViewerStateStopped:
            [self startVideoPlayback];
            break;
        case CWViewerStatePlaying:
            [self stopVideoPlayback];
            break;
        default:
            break;
    }
}

#pragma mark - Property overrides

- (void)setIncomingMessage:(Message *)incomingMessage {
    _incomingMessage = incomingMessage;
    [_incomingMessage importZip:[Message chatwalaZipURL:_incomingMessage.messageID]];
    if ([_incomingMessage.replyToMessageID length]) {
        NSURL *zipURL = [Message sentChatwalaZipURL:_incomingMessage.replyToMessageID];
        
        // TODO:
        NSError *error = nil;
        self.originalMessage = [[CWDataManager sharedInstance] importMessage:_incomingMessage.replyToMessageID chatwalaZipURL:zipURL isInboxMessage:NO withError:&error];
    }
}

#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer {
    
    if (videoPlayer == self.originalMessagePlayer) {
        [self.originalMessageView addSubview:videoPlayer.playbackView];
        [videoPlayer.playbackView setFrame:self.originalMessageView.bounds];
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.originalMessageView setAlpha:1.0f];
        }];
    }
    else {
        [self.incomingMessageView addSubview:videoPlayer.playbackView];
        [videoPlayer.playbackView setFrame:self.incomingMessageView.bounds];

        [UIView animateWithDuration:0.3f animations:^{
            [self.incomingMessageView setAlpha:1.0f];
        }];
    }
    
    if ([self.originalMessagePlayer.playbackView superview] && [self.incomingMessagePlayer.playbackView superview]) {
        [self startVideoPlayback];
    }
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error {
    NSLog(@"PROBLEM!");
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer {
    
    if (self.originalMessagePlayer == videoPlayer) {
        // Add gray screen to top video.
        [self.originalMessageView setAlpha:0.5f];
    }
    else {
        [self stopVideoPlayback];
    }
}

@end
