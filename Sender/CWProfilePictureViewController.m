//
//  CWProfilePictureViewController.m
//  Sender
//
//  Created by randall chatwala on 1/16/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWProfilePictureViewController.h"

@interface CWProfilePictureViewController ()

@end

@implementation CWProfilePictureViewController

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
    [self.navigationItem setTitle:@"UPDATE PROFILE PIC"];
    
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
