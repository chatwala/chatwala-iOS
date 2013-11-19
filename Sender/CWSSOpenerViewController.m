//
//  CWSSOpenerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSOpenerViewController.h"
#import "CWSSReviewViewController.h"
#import "CWVideoManager.h"

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
- (void)setOpenerState:(CWOpenerState)openerState
{
    [super setOpenerState:openerState];
    switch (self.openerState) {
        case CWOpenerPreview:
            //
            [self.cameraView setAlpha:0.5];
            break;
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


- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    // push to review
    CWSSReviewViewController * reviewVC = [[CWSSReviewViewController alloc]init];
    [self.navigationController pushViewController:reviewVC animated:NO];
    
}

@end
