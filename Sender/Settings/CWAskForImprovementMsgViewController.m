//
//  CWAskForImprovementMsgViewController.m
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWAskForImprovementMsgViewController.h"
#import "CWGroundControlManager.h"

@interface CWAskForImprovementMsgViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation CWAskForImprovementMsgViewController

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
    [self setTitle:@"FEEDBACK"];
    [self.label setTextColor:[UIColor chatwalaFeedbackLabel]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onSureTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
       [mailComposer setMailComposeDelegate:self];
       [mailComposer setSubject:[[CWGroundControlManager sharedInstance] feedbackEmailSubject]];
//       [mailComposer setMessageBody:[[CWGroundControlManager sharedInstance] feedbackEmailBody] isHTML:NO];
       [mailComposer setToRecipients:@[@"hello@chatwala.com"]];
       [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
