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

@property (nonatomic,strong) UIImageView * moreAnimationView;
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
    self.moreAnimationView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cw_more"]];
    [self.moreAnimationView setAnimationDuration:1];
    [self.moreAnimationView setAnimationImages:@[[UIImage imageNamed:@"cw_more1"],[UIImage imageNamed:@"cw_more2"],[UIImage imageNamed:@"cw_more3"]]];
    [self.moreAnimationView startAnimating];

}
- (void)setOpenerState:(CWOpenerState)openerState
{
    
    

    
    
    
    [super setOpenerState:openerState];
    switch (self.openerState) {
        case CWOpenerPreview:
            //
            [self.moreAnimationView removeFromSuperview];
            [self.middleButton setImage:[UIImage imageNamed:@"cw_play"] forState:UIControlStateNormal];
            [self.cameraView setAlpha:0.5];
            break;
        case CWOpenerReview:
            //
            [self.middleButton addSubview:self.moreAnimationView];
            [self.cameraView setAlpha:0.5];
            break;
        case CWOpenerReact:
            //
            [self.middleButton addSubview:self.moreAnimationView];
            [self.cameraView setAlpha:1.0];
            break;
        case CWOpenerRespond:
            //
            [self.moreAnimationView removeFromSuperview];
            [self.middleButton setImage:[UIImage imageNamed:@"cw_stop"] forState:UIControlStateNormal];
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
