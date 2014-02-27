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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startScreen = [[CWSSStartScreenViewController alloc]init];
    [self.startScreen.view setAlpha:1.0f];
    [self addChildViewController:self.startScreen];
    
    [self.view addSubview:self.startScreen.view];
    [self setNavMode:NavModeBurger];
}

@end
