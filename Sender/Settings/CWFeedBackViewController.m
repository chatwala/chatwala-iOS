//
//  CWFeedBackViewController.m
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWFeedBackViewController.h"
#import "UIColor+Additions.h"
#import "CWRatingViewController.h"
#import "CWAskForImprovementMsgViewController.h"


@implementation CWFeedBackViewController

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
    [self.label setTextColor:[UIColor chatwalaFeedbackLabel]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onYesTapped:(id)sender {

    CWRatingViewController* tocVC = [[CWRatingViewController alloc] init];
    [self.navigationController pushViewController:tocVC animated:YES];
}

- (IBAction)onNoTapped:(id)sender {

    CWAskForImprovementMsgViewController* tocVC = [[CWAskForImprovementMsgViewController alloc] init];
    [self.navigationController pushViewController:tocVC animated:YES];
}
@end
