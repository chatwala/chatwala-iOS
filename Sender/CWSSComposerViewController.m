//
//  CWSSComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSComposerViewController.h"

@interface CWSSComposerViewController ()

@end

@implementation CWSSComposerViewController

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
    [[[CWVideoManager sharedManager]recorder]setDelegate:self];
//    self.feedbackVC = [[CWFeedbackViewController alloc]initWithNibName:@"CWFeedbackViewController" bundle:[NSBundle mainBundle]];
//    [self addChildViewController:self.feedbackVC];
//    [self.view addSubview:self.feedbackVC.view];
//    self.feedbackVC.view.frame = self.view.bounds;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view insertSubview:[[[CWVideoManager sharedManager]recorder]recorderView] belowSubview:self.middleButton];
    [[[[CWVideoManager sharedManager]recorder]recorderView]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
