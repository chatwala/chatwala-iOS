//
//  CWSSOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSOpenerViewController.h"

@interface CWSSOpenerViewController ()

@end

@implementation CWSSOpenerViewController

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


- (void)enteringCameraState:(CWOpenerState)state
{
    switch (state) {
        case CWOpenerReview:
            //
            [self.cameraView setAlpha:0.5];
            break;
        case CWOpenerReact:
            //
            [self.cameraView setAlpha:1.0];
            break;
        case CWOpenerRespond:
            //
            [self.cameraView setAlpha:1.0];
            break;
    }
}


@end
