//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWMessageItem.h"
#import "CWAuthenticationManager.h"
#import "CWFlowManager.h"
#import "CWAuthenticationManager.h"
#import "AppDelegate.h"
#import "CWLandingViewController.h"
#import "CWGroundControlManager.h"



@interface CWReviewViewController () <CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSInteger playbackCount;
}
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) MFMailComposeViewController *mailComposer;
@end

@implementation CWReviewViewController

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
    
    player =[[CWVideoManager sharedManager]player];
    recorder = [[CWVideoManager sharedManager]recorder];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToBackground)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    playbackCount = 0;
    [player setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [player setVideoURL:recorder.tempFileURL];
}


- (void)goToBackground
{
    if (self.mailComposer) {
        [[self mailComposer]dismissViewControllerAnimated:NO completion:nil];
    }
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

- (void)composeMessageWithData:(NSData*)messageData
{
    self.mailComposer = [[MFMailComposeViewController alloc] init];
    [self.mailComposer setMailComposeDelegate:self];
    [self.mailComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
    
    
    if (self.incomingMessageItem.metadata.senderId) {
        [[self mailComposer] setToRecipients:@[self.incomingMessageItem.metadata.senderId]];
    }
    
    [[self mailComposer]  setMessageBody:[[CWGroundControlManager sharedInstance] emailMessage] isHTML:YES];
    [[self mailComposer]  addAttachmentData:messageData mimeType:@"application/octet-stream" fileName:@"chat.wala"];
    [self presentViewController:[self mailComposer]  animated:YES completion:nil];
}


- (CWMessageItem*)createMessageItem
{
    CWMessageItem * message = [[CWMessageItem alloc]init];
    [message setVideoURL:recorder.outputFileURL];
    message.metadata.startRecording = self.startRecordingTime;
    
    
    if ([[CWAuthenticationManager sharedInstance]isAuthenticated]) {
        [message.metadata setSenderId:[[CWAuthenticationManager sharedInstance] userEmail]];
    }
    
    if (self.incomingMessageItem) {
        [message.metadata setRecipientId:self.incomingMessageItem.metadata.senderId];
        [message.metadata setThreadId:self.incomingMessageItem.metadata.threadId];
        [message.metadata setThreadIndex:self.incomingMessageItem.metadata.threadIndex+1];
    }
    return message;
}


- (NSData*)createMessageData
{
    CWMessageItem * message = [self createMessageItem];
    [message exportZip];
    return [NSData dataWithContentsOfURL:[message zipURL]];
}

- (IBAction)onRecordAgain:(id)sender {
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    
    if (self.incomingMessageItem) {
        // responding
        
        [CWAnalytics event:@"Re-do Message" withCategory:@"Preview" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [CWAnalytics event:@"Re-do Message" withCategory:@"Preview Original Message" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    
    
}

- (IBAction)onSend:(id)sender {
    if (self.incomingMessageItem) {
        // responding
        [CWAnalytics event:@"Send Message" withCategory:@"Preview" withLabel:@"" withValue:@(playbackCount)];
        
        
    }else{
        [CWAnalytics event:@"Send Message" withCategory:@"Preview Original Message" withLabel:@"" withValue:@(playbackCount)];

        
    }
    
    [player stop];
    [self composeMessageWithData:[self createMessageData]];
}


#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer
{
    [self showVideoPreview];
}

- (void)showVideoPreview
{
//    [self.view insertSubview:self.player.playbackView belowSubview:self.recordAgainButton];
    [self.previewView addSubview:player.playbackView];
    self.previewView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5);
    player.playbackView.frame = self.previewView.bounds;
    
    
    [player playVideo];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    playbackCount++;
    [player replayVideo];
}
- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    
    switch (result) {
        case MFMailComposeResultSent:
            {
                if (self.incomingMessageItem) {
                    [CWAnalytics event:@"Send Email" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
                }else{
                    [CWAnalytics event:@"Send Email" withCategory:@"Send Message" withLabel:@"" withValue:nil];
                }
                AppDelegate * appdel = (AppDelegate *)[[UIApplication sharedApplication]delegate ];
                
                [appdel.landingVC setFlowDirection:eFlowToStartScreenSent];
                [[CWAuthenticationManager sharedInstance]didSkipAuth];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            break;
    
        case MFMailComposeResultCancelled:
            if (self.incomingMessageItem) {
                [CWAnalytics event:@"Cancel Email" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"Cancel Email" withCategory:@"Send Message" withLabel:@"" withValue:nil];
            }
            [self.player replayVideo];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.mailComposer= nil;
}

@end
