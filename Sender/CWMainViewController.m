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
    
    self.startScreen = [[CWSSStartScreenViewController alloc]init];
    [self.startScreen.view setAlpha:0.99];
    [self addChildViewController:self.startScreen];
    
    
    [self.view addSubview:self.startScreen.view];
    
    [self setNavMode:NavModeBurger];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
