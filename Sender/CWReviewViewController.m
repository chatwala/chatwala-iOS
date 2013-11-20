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


static NSString * emailString = @"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>\
<html xmlns='http://www.w3.org/1999/xhtml'>\
<head>\
<meta name='viewport' content='width=device-width' />\
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />\
<title>Chatwala Message</title>\
<link rel='stylesheet' type='text/css' href='stylesheets/email.css' />\
</head>\
<body bgcolor='#FFFFFF'>\
<table class='body-wrap'>\
<tr>\
<td></td>\
<td class='container' bgcolor='#FFFFFF'>\
<div class='content'>\
<table>\
<tr>\
<td><h3>You have a new message!</h3>\
<p class='callout'>\
Chatwala is a new way to communicate with your friends through video messaging.\
<br/><a href='http://google.com'>Get the App! &raquo;</a>\
</p>\
</body>\
</html>";

@interface CWReviewViewController () <CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
}
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [player setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)composeMessageWithData:(NSData*)messageData
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"CW msg"];
    [mc setMessageBody:emailString isHTML:YES];
    [mc addAttachmentData:messageData mimeType:@"application/octet-stream" fileName:@"chat.wala"];
    [self presentViewController:mc animated:YES completion:nil];
}

- (CWMessageItem*)createMessageItem
{
    CWMessageItem * message = [[CWMessageItem alloc]init];
    [message setVideoURL:recorder.outputFileURL];
    message.metadata.startRecording = self.startRecordingTime;
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
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)onSend:(id)sender {
    
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
    [player.playbackView setFrame:self.previewView.bounds];
    [player playVideo];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    [player replayVideo];
}
- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    
    switch (result) {
        case MFMailComposeResultSent:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
