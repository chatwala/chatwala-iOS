//
//  CWSSComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSComposerViewController.h"
#import "CWSSReviewViewController.h"

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
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view insertSubview:[[[CWVideoManager sharedManager]recorder]recorderView] belowSubview:self.middleButton];
    [[[[CWVideoManager sharedManager]recorder]recorderView]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5)];
}


- (void)showReview
{
    CWSSReviewViewController * reviewVC = [[CWSSReviewViewController alloc]init];
    [reviewVC setStartRecordingTime:0];
    [self.navigationController pushViewController:reviewVC animated:NO];
    
    [[[CWVideoManager sharedManager] recorder] stopSession];
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch * touch = [touches anyObject];
    BOOL wasButton = CGRectContainsPoint(self.middleButton.frame, [touch locationInView:self.view]);

    // get duration
    
    if (wasButton) {
        [CWAnalytics event:@"COMPLETE_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    }else{
        [CWAnalytics event:@"COMPLETE_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    }
}


@end
