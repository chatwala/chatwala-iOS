//
//  CWMainViewController.m
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMainViewController.h"
#import "AppDelegate.h"
#import "CWSSStartScreenViewController.h"


@interface CWMainViewController ()
@property (nonatomic,strong) UIButton * menuButton;
@property (nonatomic,strong) UIBarButtonItem * menuBtn;
@property (nonatomic,strong) CWSSStartScreenViewController * startScreen;
@end

@implementation CWMainViewController

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
    // Do any additional setup after loading the view from its nib.
//    [self.navigationController setNavigationBarHidden:YES];
//    self.menuButton = [UIButton buttonWithType:UIBarButtonItemStyleBordered];
//    [self.menuButton addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
//    [self.menuButton setBackgroundColor:[UIColor grayColor]];
//    [[self menuButton]setFrame:CGRectMake(20, 20, 50, 50)];
//    [self.view addSubview:self.menuButton];
    
    
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    [button addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    self.menuBtn = [[UIBarButtonItem alloc]initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:self.menuBtn];
    
    
    self.startScreen = [[CWSSStartScreenViewController alloc]init];
    [self.startScreen.view setAlpha:0.99];
    [self addChildViewController:self.startScreen];
    
    
    [self.view addSubview:self.startScreen.view];
    
}

- (void)onTap
{
    AppDelegate * appdel = [[UIApplication sharedApplication]delegate];
    if (appdel.drawController.openSide == MMDrawerSideNone) {
        [appdel.drawController openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            //
        }];
    }else{
        [appdel.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
            //
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
