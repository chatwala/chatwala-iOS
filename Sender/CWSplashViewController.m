//
//  CWSplashViewController.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 4/21/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWSplashViewController.h"

@interface CWSplashViewController ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation CWSplashViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:self.imageView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"Splash-Background"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.imageView.frame = self.view.frame;
}

@end
