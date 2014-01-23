//
//  CWViewController.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWViewController.h"
#import "UIViewController+MMDrawerController.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

@interface CWViewController ()

//@property (nonatomic,strong) UIImageView * messageSentView;
@end

@implementation CWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.burgerButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(onTap:)];
    
    self.closeButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Close-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(onTap:)];

    
    UIView * spacer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spacer]];
}


- (void)setNavMode:(NavMode)mode
{
    switch (mode) {
        case NavModeNone:
            // none
            [self.navigationItem setLeftBarButtonItems:@[]];
            break;
            
        case NavModeBurger:
            // burger
            [self.navigationItem setLeftBarButtonItem:self.burgerButton];
            break;
            
        case NavModeClose:
            // close
            [self.navigationItem setLeftBarButtonItems:@[self.closeButton]];
            break;
            
        default:
            [self setNavMode:NavModeNone];
            break;
    }
}

- (void)onTap:(id)sender
{
     if ([sender isEqual:self.burgerButton])
    {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        [self rotateBurgerBar];
    }
    
    if ([sender isEqual:self.closeButton]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)rotateBurgerBar
{
    MMDrawerController* drawer = self.mm_drawerController;
    CGFloat duration = (drawer.maximumLeftDrawerWidth) / drawer.animationVelocity;

    [UIView animateWithDuration:duration animations:^{

        UIView* burgerView = [self.burgerButton valueForKey:@"view"];
        burgerView.backgroundColor = [UIColor orangeColor];
        burgerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        if(drawer.openSide == MMDrawerSideNone)
        {
            //current state is closed so we are switching it over to the "opened" state
            burgerView.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
        }
        else
        {
            burgerView.transform = CGAffineTransformIdentity;
        }
    }];
}
@end
