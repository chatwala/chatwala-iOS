//
//  CWGoogleAuthViewController.m
//  Sender
//
//  Created by Khalid on 12/2/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWGoogleAuthViewController.h"

@interface CWGoogleAuthViewController ()

@end

@implementation CWGoogleAuthViewController

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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    
//    __block CWGoogleAuthViewController * blockSelf= se
//    [self setPopViewBlock:^{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }];
    
//    self
    
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.backButton removeFromSuperview];
    [self.forwardButton removeFromSuperview];
    NSLog(@"");
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
