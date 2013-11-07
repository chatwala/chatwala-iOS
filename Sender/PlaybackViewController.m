//
//  PlaybackViewController.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "PlaybackViewController.h"
#import "VideoPlayerViewController.h"
#import "CWMessageItem.h"

@interface PlaybackViewController () <MFMailComposeViewControllerDelegate,VideoPlayerViewDelegate>
@property (nonatomic,strong) VideoPlayerViewController * videoPlayerVC;
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@end

@implementation PlaybackViewController

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
    [self.videoPlayerVC setLoops:YES];
    [self.videoPlayerVC setDelegate:self];
    [self.videoPlayerVC.view setFrame:self.playbackView.bounds];
    [self.playbackView addSubview:self.videoPlayerVC.view];
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

- (IBAction)onRecordAgain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSend:(id)sender {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"pho msg"];
    [mc setMessageBody:@"You've got video!" isHTML:NO];
    
    // send
    
    CWMessageItem * message = [[CWMessageItem alloc]init];
    [message setVideoURL:self.videoURL];
    [message exportZip];
    
    
    NSData * messageData = [NSData dataWithContentsOfURL:message.zipURL];
    
    //    [mc setToRecipients:toRecipents];
    [mc addAttachmentData:messageData mimeType:@"application/zip" fileName:@"message.chatwala"];
    // Present mail view controller on screen
    
    [self.videoPlayerVC pause];
    [self presentViewController:mc animated:YES completion:NULL];
    
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    
    switch (result) {
        case MFMailComposeResultSent:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            [self.videoPlayerVC resume];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoPlayerViewControllerDidFinishPlayback
{
    
}

@end
