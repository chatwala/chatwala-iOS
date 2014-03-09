//
//  CWAppFeedBackViewController.m
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWAppFeedBackViewController.h"
#import "UIColor+Additions.h"
#import "CWRatingViewController.h"
#import "CWAskForImprovementMsgViewController.h"


@implementation CWAppFeedBackViewController

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

- (IBAction)onYesTapped:(id)sender {

    CWRatingViewController* tocVC = [[CWRatingViewController alloc] init];
    [self.navigationController pushViewController:tocVC animated:YES];
}

- (IBAction)onNoTapped:(id)sender {

    CWAskForImprovementMsgViewController* tocVC = [[CWAskForImprovementMsgViewController alloc] init];
    [self.navigationController pushViewController:tocVC animated:YES];
}
@end
