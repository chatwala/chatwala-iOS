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
#import "AOFetchUtilities.h"

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

@property (nonatomic) UIView *sentMessageView;
@property (nonatomic) UIView *incomingMessageView;

@property (nonatomic) CWVideoPlayer *sentMessagePlayer;
@property (nonatomic) CWVideoPlayer *incomingMessagePlayer;

@property (nonatomic) Message *originalSentMessage;
@property (nonatomic) Message *lastSentMessage;

@property (nonatomic, assign) CWViewerState viewerState;
@property (nonatomic) CWLoadingViewController *loadingVC;

@property (nonatomic,assign) BOOL incomingMessageIsConversationStarter;
@property (nonatomic,assign) BOOL completedOriginalSentMessagePlayback;

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
    
    self.sentMessageView = [[UIView alloc] init];
    self.sentMessageView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.sentMessageView belowSubview:self.middleButton];
    
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
    
    self.sentMessageView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height / 2.0f);
    self.sentMessageView.frame = CGRectIntegral(self.sentMessageView.frame);
    [self.sentMessageView setAlpha:0.0f];
    
    self.incomingMessageView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.sentMessageView.frame), self.view.frame.size.width, self.view.frame.size.height - self.sentMessageView.frame.size.height);
    [self.incomingMessageView setAlpha:0.0f];

    self.middleButton.frame = CGRectMake(0.0f, 0.0f, 90.0f, 90.0f);
    
    [self.middleButton setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [self.middleButton setButtonState:eButtonStatePlay];
    [self.middleButton setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.middleButton];
    [self.view bringSubviewToFront:self.loadingVC.view];
    
    NSAssert(self.incomingMessage, @"CWViewerController:  Incoming message should always be set.");
    
    if ([self.incomingMessage.threadIndex integerValue] == 0) {
        self.incomingMessageIsConversationStarter = YES;
        [self.sentMessageView setAlpha:0.5f];
    }
    else {
        NSInteger originalMessageThreadIndex = [self.incomingMessage.threadIndex integerValue] - 1;
        self.originalSentMessage = [AOFetchUtilities messageWithThreadID:self.incomingMessage.threadID withThreadIndex:originalMessageThreadIndex];
    }
    
    
    NSInteger lastReplyThreadIndex = [self.incomingMessage.threadIndex integerValue] + 1;
    self.lastSentMessage = [AOFetchUtilities messageWithThreadID:self.incomingMessage.threadID withThreadIndex:lastReplyThreadIndex];
    
    [self downloadMessagesAndConfigureVideoPlayers];
}


// TODO: this is horrible, need to refactor so messages has a type class to automatically know
// where to save a message in the directory structure. [RK]

- (void)downloadMessagesAndConfigureVideoPlayers {
    __block NSInteger numberOfMessagesToDownload = 0;
    
    NSString *incomingMessageReadURL = nil;
    NSString *originalMessageReadURL = nil;
    NSString *lastReplyReadURL = nil;
    
    if (![self.incomingMessage inboxZipURL]) {
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
        [self.incomingMessage importZip:[self.incomingMessage inboxZipURL]];
    }
    
    NSURL *originalMessageZipURL = [self.originalSentMessage sentChatwalaZipURL];
    if (!originalMessageZipURL && !self.incomingMessageIsConversationStarter) {
        // download from replyToReadURL
        originalMessageReadURL = self.originalSentMessage.readURL;
        
        if (![originalMessageReadURL length]) {
            [self showErrorAndCloseViewer];
            return;
        }
        else {
            numberOfMessagesToDownload++;
        }
    }
    else if (!self.incomingMessageIsConversationStarter) {
        [self.originalSentMessage importZip:[self.originalSentMessage sentChatwalaZipURL]];
    }
    
    if (![self.lastSentMessage sentChatwalaZipURL]) {
        // download from readurl into inbox
        lastReplyReadURL = self.lastSentMessage.readURL;
        
        if (![lastReplyReadURL length]) {
            [self showErrorAndCloseViewer];
            return;
        }
        else {
            numberOfMessagesToDownload++;
        }
    }
    else {
        [self.lastSentMessage importZip:[self.lastSentMessage sentChatwalaZipURL]];
    }
    
    if (!numberOfMessagesToDownload) {
        [self configureDefaultVideoPlayers];
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
                    [self.incomingMessage importZip:[self.incomingMessage inboxZipURL]];
                    [self configureDefaultVideoPlayers];
                }
            }
            else {
                [self showErrorAndCloseViewer];
            }
        }];
    }
    
    if (originalMessageReadURL) {
        [downloader downloadMessageFromReadURL:originalMessageReadURL forMessageID:self.originalSentMessage.messageID toSentbox:YES completion:^(NSError *error, NSURL *url, NSString *messageID) {
            
            numberOfMessagesToDownload--;
            
            if (url && messageID) {
                
                NSError *error = nil;
                [self.originalSentMessage importZip:[self.originalSentMessage sentChatwalaZipURL]];
                
                if (error) {
                    [self showErrorAndCloseViewer];
                }
                else if (numberOfMessagesToDownload == 0) {
                    // do work;
                    [self configureDefaultVideoPlayers];
                }
            }
            else {
                [self showErrorAndCloseViewer];
            }
        }];
    }
    
    if (lastReplyReadURL) {
        [downloader downloadMessageFromReadURL:lastReplyReadURL forMessageID:self.lastSentMessage.messageID toSentbox:YES completion:^(NSError *error, NSURL *url, NSString *messageID) {
            
            numberOfMessagesToDownload--;
            
            if (url && messageID) {
                
                NSError *error = nil;
                [self.lastSentMessage importZip:[self.lastSentMessage sentChatwalaZipURL]];
                
                if (error) {
                    [self showErrorAndCloseViewer];
                }
                else if (numberOfMessagesToDownload == 0) {
                    // do work;
                    [self configureDefaultVideoPlayers];
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

- (void)configureDefaultVideoPlayers {
    self.completedOriginalSentMessagePlayback = NO;
    
    if (!self.incomingMessageIsConversationStarter) {
        self.sentMessagePlayer = [[CWVideoPlayer alloc] init];
        [self.sentMessagePlayer setVideoURL:[self.originalSentMessage sentboxVideoFileURL]];
        [self.sentMessagePlayer setDelegate:self];
        self.sentMessagePlayer.shouldMuteAudio = YES;
    }
    else {
        [self loadLastSentMessage];
    }
    
    self.incomingMessagePlayer = [[CWVideoPlayer alloc] init];
    [self.incomingMessagePlayer setVideoURL:[self.incomingMessage inboxVideoFileURL]];
    [self.incomingMessagePlayer setDelegate:self];
    
    [self hideLoadingView];
}

- (void)loadLastSentMessage {
    
    [self.sentMessageView setAlpha:0.5f];
    self.sentMessagePlayer = [[CWVideoPlayer alloc] init];
    [self.sentMessagePlayer setVideoURL:[self.lastSentMessage sentboxVideoFileURL]];
    [self.sentMessagePlayer setDelegate:self];
    self.sentMessagePlayer.shouldMuteAudio = NO;
}

- (void)startVideoPlayback {
    CMTime targetTime = CMTimeMakeWithSeconds([self.originalSentMessage.startRecording doubleValue] , NSEC_PER_SEC);
    [self.sentMessagePlayer seekToTime:targetTime];
    
    self.viewerState = CWViewerStatePlaying;
    [self.middleButton setButtonState:eButtonStateStop];
    
    [self.sentMessagePlayer playVideo];
    [self.incomingMessagePlayer playVideo];
}

- (void)stopVideoPlayback {
    self.viewerState = CWViewerStateStopped;
    [self.middleButton setButtonState:eButtonStatePlay];
    [self.sentMessageView setAlpha:1.0f];
    
    [self.sentMessagePlayer stop];
    [self.incomingMessagePlayer stop];
}

- (void)cleanUpPlayers {
    
    self.incomingMessageIsConversationStarter = NO;
    self.completedOriginalSentMessagePlayback = NO;
    
    [self.sentMessagePlayer cleanUp];
    [self.incomingMessagePlayer cleanUp];
    
    self.sentMessagePlayer = nil;
    self.incomingMessagePlayer = nil;
}

#pragma mark - Helper methods

- (void)showLoadingView {
    
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
    
    if (videoPlayer == self.sentMessagePlayer) {
        [self.sentMessageView addSubview:videoPlayer.playbackView];
        [videoPlayer.playbackView setFrame:self.sentMessageView.bounds];
        
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.sentMessageView setAlpha:1.0f];
        }];
    
        if (self.completedOriginalSentMessagePlayback) {
            [self.sentMessagePlayer playVideo];
        }
    }
    else {
        [self.incomingMessageView addSubview:videoPlayer.playbackView];
        [videoPlayer.playbackView setFrame:self.incomingMessageView.bounds];

        [UIView animateWithDuration:0.3f animations:^{
            [self.incomingMessageView setAlpha:1.0f];
        }];
    }
    
//    if ([self.sentMessagePlayer.playbackView superview] && [self.incomingMessagePlayer.playbackView superview] && !self.completedFirstReply) {
//        [self startVideoPlayback];
//    }
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error {
    NSLog(@"Error loading video in viewer.");
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer {
    
    if (self.sentMessagePlayer == videoPlayer) {
        // Add gray screen to top video.
        
        if (self.incomingMessageIsConversationStarter) {
            [self stopVideoPlayback];
            [self configureDefaultVideoPlayers];
            return;
        }
        
        if (!self.completedOriginalSentMessagePlayback) {
            // Load lastSentMessage
            self.completedOriginalSentMessagePlayback = YES;
            [self loadLastSentMessage];
        }
        else {
            [self stopVideoPlayback];
            [self configureDefaultVideoPlayers];
        }
    }
    else if (self.incomingMessagePlayer == videoPlayer) {
        [self.incomingMessageView setAlpha:0.5f];
    }
}

@end