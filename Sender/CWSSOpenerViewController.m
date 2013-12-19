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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.openerMessageLabel setText:[[CWGroundControlManager sharedInstance] openerScreenMessage]];
    [self.recordMessageLabel setText:[[CWGroundControlManager sharedInstance] replyMessage]];
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
    [self.playbackView setAlpha:1];
    [self.recordMessageLabel setAlpha:0];
    
    
    switch (self.openerState) {
        case CWOpenerPreview:
        
            [self.middleButton setButtonState:eButtonStatePlay];
            [self.cameraView setAlpha:0.5];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:1];
            }];
            
        }
            break;
            
            
        case CWOpenerReview:
            //
            [CWAnalytics event:@"Start" withCategory:@"Review" withLabel:@"" withValue:nil];
            [self.middleButton setButtonState:eButtonStateStop];
            [self.cameraView setAlpha:0.5];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:0];
            }];
            
        }
            break;
        case CWOpenerReact:
            //
            [CWAnalytics event:@"Start" withCategory:@"React" withLabel:@"" withValue:nil];
            [self.middleButton setButtonState:eButtonStateStop];
            [self.cameraView setAlpha:1.0];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:0];
            }];
            
        }
            break;
        case CWOpenerRespond:
            //
            [CWAnalytics event:@"Start" withCategory:@"Respond" withLabel:@"" withValue:nil];
            [self.middleButton setButtonState:eButtonStateStop];
            [self.cameraView setAlpha:1.0];
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.openerMessageLabel setAlpha:0];
                [self.playbackView setAlpha:0.3];
                [self.recordMessageLabel setAlpha:1];
            }];
        }
            break;
    }
}



- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
{
    [super recorderRecordingFinished:recorder];
    
    if(self.openerState == CWOpenerRespond)
    {
        // push to review
        CWSSReviewViewController * reviewVC = [[CWSSReviewViewController alloc]init];
        [reviewVC setStartRecordingTime:[self.player videoLength] - self.startRecordTime];
        [reviewVC setIncomingMessageItem:self.messageItem];
        [self.navigationController pushViewController:reviewVC animated:NO];
    }
    
}

@end
