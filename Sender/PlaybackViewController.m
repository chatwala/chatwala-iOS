//
//  PlaybackViewController.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "PlaybackViewController.h"
#import "VideoPlayerViewController.h"

@interface PlaybackViewController () <MFMailComposeViewControllerDelegate>
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.videoPlayerVC = [[VideoPlayerViewController alloc]init];
    [self.videoPlayerVC setURL:self.videoURL];
    [self.videoPlayerVC.view setFrame:self.playbackView.bounds];
    [self.playbackView addSubview:self.videoPlayerVC.view];
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
    NSData * videoData = [NSData dataWithContentsOfURL:self.videoURL];
//    [mc setToRecipients:toRecipents];
    [mc addAttachmentData:videoData mimeType:@"chatwalla/video" fileName:@"msg.chatwalla"];
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

@end
