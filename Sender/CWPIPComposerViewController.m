//
//  CWPIPComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWPIPComposerViewController.h"
#import "CWPIPReviewViewController.h"
@interface CWPIPComposerViewController ()

@end

@implementation CWPIPComposerViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showReview
{
    CWPIPReviewViewController * reviewVC = [[CWPIPReviewViewController alloc]init];
    [reviewVC setStartRecordingTime:0];
    [self.navigationController pushViewController:reviewVC animated:YES];
}

@end