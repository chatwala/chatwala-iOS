//
//  CWAskForImprovementMsgViewController.m
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWAskForImprovementMsgViewController.h"

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
    [self.navigationItem setTitle:@"FEEDBACK"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.label setTextColor:[UIColor chatwalaFeedbackLabel]];
}

- (IBAction)onSureTapped:(id)sender {
}
@end
