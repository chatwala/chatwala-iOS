//
//  CWAskForImprovementMsgViewController.m
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWAskForImprovementMsgViewController.h"
#import "CWGroundControlManager.h"
#import "UIColor+Additions.h"

@interface CWAskForImprovementMsgViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation CWAskForImprovementMsgViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self setTitle:@"FEEDBACK"];
    [self.label setTextColor:[UIColor chatwalaFeedbackLabel]];
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
    else
    {
        UIAlertView * cantSendEmail = [[UIAlertView alloc] initWithTitle:@"Email not setup" message:@"In order to send us a message you need to setup your email" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        
        [cantSendEmail show];
    }
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    __weak CWAskForImprovementMsgViewController* weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
}

@end
