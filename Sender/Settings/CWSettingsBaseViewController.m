//
//  CWSettingsBaseViewController.m
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWSettingsBaseViewController.h"

@interface CWSettingsBaseViewController ()

@end

@implementation CWSettingsBaseViewController

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
	UIImage * backImg = [UIImage imageNamed:@"back_button"];
    UIButton * backBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:backImg forState:UIControlStateNormal];
    UIBarButtonItem* backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:backBtnItem];
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
