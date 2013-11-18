//
//  CWPIPOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWPIPOpenerViewController.h"

@interface CWPIPOpenerViewController ()

@end

@implementation CWPIPOpenerViewController

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

- (void)enteringCameraState:(CWOpenerState)state
{
    switch (state) {
        case CWOpenerReview:
            //
            [self.cameraView setHidden:YES];
            break;
        case CWOpenerReact:
            //
            [self.cameraView setHidden:NO];
            break;
        case CWOpenerRespond:
            //
            [self.cameraView setHidden:NO];
            break;
    }
}

@end
