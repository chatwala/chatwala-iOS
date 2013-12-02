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
#import "CWGroundControlManager.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.openerMessageLabel setText:[[CWGroundControlManager sharedInstance] openerScreenMessage]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    UITouch * touch = [touches anyObject];
    BOOL wasButton = CGRectContainsPoint(self.middleButton.frame, [touch locationInView:self.view]);
    
    if (wasButton) {
        [CWAnalytics event:@"Play Message" withCategory:@"Message" withLabel:@"Tap Button" withValue:nil];
    }else{
        [CWAnalytics event:@"Play Message" withCategory:@"Message" withLabel:@"Tap Screen" withValue:nil];
    }
    
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
            [CWAnalytics event:@"Start" withCategory:@"Review" withLabel:@"" withValue:nil];
            [self.middleButton addSubview:self.moreAnimationView];
            [self.cameraView setAlpha:0.5];
            break;
        case CWOpenerReact:
            //
            [CWAnalytics event:@"Start" withCategory:@"React" withLabel:@"" withValue:nil];
            [self.middleButton addSubview:self.moreAnimationView];
            [self.cameraView setAlpha:1.0];
            break;
        case CWOpenerRespond:
            //
            [CWAnalytics event:@"Start" withCategory:@"Respond" withLabel:@"" withValue:nil];
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
    [reviewVC setStartRecordingTime:[self.player videoLength] - self.startRecordTime];
    [reviewVC setIncomingMessageItem:self.messageItem];
    [self.navigationController pushViewController:reviewVC animated:NO];
    
}

@end
