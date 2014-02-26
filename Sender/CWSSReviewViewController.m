//
//  CWSSViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSSReviewViewController.h"
#import "CWMiddleButton.h"

@implementation CWSSReviewViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.sendButton setButtonState:eButtonStateShare];
    [self.sendButton.button addTarget:self action:@selector(onMiddleButtonTap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onMiddleButtonTap {
    
    [self onSend:nil];
}

@end
