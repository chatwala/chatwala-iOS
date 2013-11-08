//
//  CWStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWStartScreenViewController.h"

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
