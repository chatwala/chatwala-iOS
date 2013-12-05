//
//  CWStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWStartScreenViewController.h"
#import "CWVideoManager.h"
#import "CWFlowManager.h"
#import "CWComposerViewController.h"
#import "CWErrorViewController.h"
#import "CWAuthenticationManager.h"
#import "CWAuthRequestViewController.h"
#import "CWGroundControlManager.h"

@interface CWStartScreenViewController ()

@end

@implementation CWStartScreenViewController

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
    [self.navigationController setNavigationBarHidden:YES];

    

//    NSError * error = [[[CWVideoManager sharedManager]recorder]setupSession];
//    if (error) {
//        // handle session error
//        CWErrorViewController * vc = [[CWErrorViewController alloc]init];
//        [vc setError:error];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    [[[CWVideoManager sharedManager]recorder]setupSession];
   
    
    
    

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.startScreenMessageLabel setText:[[CWGroundControlManager sharedInstance] startScreenMessage]];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.startButton];
    
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:self.view.bounds];
    
    
    /*

    if ([[CWAuthenticationManager sharedInstance]shouldShowAuth]) {
        // not-authenticated
        CWAuthRequestViewController * vc = [[CWAuthRequestViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
     */
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    
    
    BOOL wasButton = CGRectContainsPoint(self.startButton.frame, [touch locationInView:self.view]);
    
    if (wasButton) {
        [CWAnalytics event:@"Complete Recording" withCategory:@"Original Message" withLabel:@"Tap Button" withValue:nil];
    }else{
        [CWAnalytics event:@"Complete Recording" withCategory:@"Original Message" withLabel:@"Tap Screen" withValue:nil];
    }
    CWComposerViewController * composerVC = [[CWFlowManager sharedInstance]composeVC];
    [self.navigationController pushViewController:composerVC animated:NO];
}


@end
