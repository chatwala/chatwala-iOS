//
//  CWSSStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSStartScreenViewController.h"
#import "CWVideoManager.h"

@interface CWSSStartScreenViewController ()

@end

@implementation CWSSStartScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.startButton];
    
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
