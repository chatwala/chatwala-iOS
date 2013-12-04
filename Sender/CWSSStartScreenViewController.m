//
//  CWSSStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSStartScreenViewController.h"
#import "CWSSComposerViewController.h"
#import "CWVideoManager.h"
#import "CWFlowManager.h"
#import "CWMiddleButton.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.middleButton setButtonState:eButtonStateRecord];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.middleButton];
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5)];
    
}


@end
