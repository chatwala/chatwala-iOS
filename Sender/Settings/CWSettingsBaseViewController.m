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
    if (![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
        UIImage * backImg = [UIImage imageNamed:@"back_button"];
        UIButton * backBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        [backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImage:backImg forState:UIControlStateNormal];
        UIBarButtonItem* backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:backBtnItem];
    }
    else
    {
        UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onFeedbackDone:)];

        [self.navigationItem setRightBarButtonItem:doneBtn];
    }

    [self.navigationItem.titleView setTintColor:[UIColor chatwalaFeedbackLabel]];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"Avenir" size:16.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];

        titleView.textColor = [UIColor chatwalaFeedbackLabel]; // Change to desired color

        self.navigationItem.titleView = titleView;
     
    }
    titleView.text = title;
    [titleView sizeToFit];
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

-(void)onSettingsDone:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
