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
#import "CWSSOpenerViewController.h"
#import "CWLoadingViewController.h"
#import "CWMessagesDownloader.h"


#if defined(USE_DEV_SERVER)
NSString *const BaseReadURLString = @"https://chatwalanonprod.blob.core.windows.net/dev-messages/";
#elif defined(USE_QA_SERVER)
NSString *const BaseReadURLString = @"https://chatwalanonprod.blob.core.windows.net/qa-messages/";
#else
NSString *const BaseReadURLString = @"https://chatwalaprods1.blob.core.windows.net/messages/";
#endif

typedef void (^CWViewerDownloadMessagesToViewCompletionBlock)(BOOL success);

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
@property (nonatomic) CWLoadingViewController *loadingVC;

@end

@implementation CWViewerViewController

#pragma mark - ViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.loadingVC = [[CWLoadingViewController alloc] init];
    [self.view addSubview:self.loadingVC.view];
    [self.loadingVC.view setAlpha:1.0f];
    [self.loadingVC stopAnimating];
    
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
    
    self.loadingVC.view.frame = self.view.frame;
    
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
    [self.view bringSubviewToFront:self.loadingVC.view];
    
    NSAssert(self.incomingMessage, @"CWViewerController:  Incoming message should always be set.");
    
    
    [self downloadMessagesAndConfigureVideoPlayers];
}


// TODO: this is horrible, need to refactor so messages has a type class to automatically know
// where to save a message in the directory structure. [RK]

- (void)downloadMessagesAndConfigureVideoPlayers {
    __block NSInteger numberOfMessagesToDownload = 0;
    
    NSString *incomingMessageReadURL = nil;
    NSString *originalMessageReadURL = nil;
    
    if (![Message inboxZipURL:self.incomingMessage.messageID]) {
        // download from readurl into inbox
        incomingMessageReadURL = self.incomingMessage.readURL;
        
        if (![incomingMessageReadURL length]) {
            [self showErrorAndCloseViewer];
            return;
        }
        else {
            numberOfMessagesToDownload++;
        }
    }
    else {
        [self.incomingMessage importZip:[Message inboxZipURL:self.incomingMessage.messageID]];
    }
    
    NSURL *originalMessageZipURL = [Message sentChatwalaZipURL:self.incomingMessage.replyToMessageID];
    if (!originalMessageZipURL) {
        // download from replyToReadURL
        originalMessageReadURL = [self readURLForOriginalMessage];
        
        if (![originalMessageReadURL length]) {
            [self showErrorAndCloseViewer];
            return;
        }
        else {
            numberOfMessagesToDownload++;
        }
    }
    else {
        NSError *error = nil;
        self.originalMessage = [[CWDataManager sharedInstance] importMessage:self.incomingMessage.replyToMessageID chatwalaZipURL:[Message sentChatwalaZipURL:self.incomingMessage.replyToMessageID] withError:&error];
    }
    
    if (!numberOfMessagesToDownload) {
        [self configureVideoPlayers];
        return;
    }
    else {
        [self showLoadingView];
    }
    
    CWMessagesDownloader *downloader = [[CWMessagesDownloader alloc] init];
    
    if (incomingMessageReadURL) {
        [downloader downloadMessageFromReadURL:incomingMessageReadURL forMessageID:self.incomingMessage.messageID toSentbox:NO completion:^(NSError *error, NSURL *url, NSString *messageID) {
            
            numberOfMessagesToDownload--;
            
            if (url && messageID) {
                if (numberOfMessagesToDownload == 0) {
                    // do work;
                    [self.incomingMessage importZip:[Message inboxZipURL:self.incomingMessage.messageID]];
                    [self configureVideoPlayers];
                }
            }
            else {
                [self showErrorAndCloseViewer];
            }
        }];
    }
    
    if (originalMessageReadURL) {
        [downloader downloadMessageFromReadURL:originalMessageReadURL forMessageID:self.incomingMessage.replyToMessageID toSentbox:YES completion:^(NSError *error, NSURL *url, NSString *messageID) {
            
            numberOfMessagesToDownload--;
            
            if (url && messageID) {
                
                NSError *error = nil;
                self.originalMessage = [[CWDataManager sharedInstance] importMessage:messageID chatwalaZipURL:url withError:&error];
                
                if (error) {
                    [self showErrorAndCloseViewer];
                }
                else if (numberOfMessagesToDownload == 0) {
                    // do work;
                    [self configureVideoPlayers];
                }
            }
            else {
                [self showErrorAndCloseViewer];
            }
        }];
    }
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
    [self.originalMessagePlayer setVideoURL:[Message sentboxVideoFileURL:self.originalMessage.messageID]];
    [self.originalMessagePlayer setDelegate:self];
    self.originalMessagePlayer.shouldMuteAudio = YES;
    
    self.incomingMessagePlayer = [[CWVideoPlayer alloc] init];
    [self.incomingMessagePlayer setVideoURL:[Message inboxVideoFileURL:self.incomingMessage.messageID]];
    [self.incomingMessagePlayer setDelegate:self];
    
    [self hideLoadingView];
}

- (void)startVideoPlayback {
    CMTime targetTime = CMTimeMakeWithSeconds([self.originalMessage.startRecording doubleValue] , NSEC_PER_SEC);
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

#pragma mark - Helper methods

- (void)showLoadingView {
    
    [self.loadingVC.loadingLabel setText:@"Downloading messages for viewing."];
    
    // Download the message to the sent folder and try zip URL again
    [self.loadingVC.view setAlpha:1.0f];
    [self.loadingVC restartAnimation];
}

- (void)hideLoadingView {
    
    // Download the message to the sent folder and try zip URL again
    [self.loadingVC.view setAlpha:0.0f];
    [self.loadingVC stopAnimating];
}

- (void)showErrorAndCloseViewer {

    [self hideLoadingView];
    [self stopVideoPlayback];
    [self cleanUpPlayers];
    
    [SVProgressHUD showErrorWithStatus:@"Cannot open message for viewing."];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (NSString *)readURLForOriginalMessage {
    
    return ([self.incomingMessage.replyToReadURL length] ? self.incomingMessage.replyToReadURL : [BaseReadURLString stringByAppendingString:self.incomingMessage.replyToMessageID]);
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