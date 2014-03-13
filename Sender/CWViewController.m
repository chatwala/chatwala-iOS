//
//  CWViewController.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "CWConstants.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

@interface CWViewController ()
//@property (nonatomic,strong) UIImageView * messageSentView;
@end

@implementation CWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.burgerButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(onTap:)];
    
    self.closeButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Close-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(onTap:)];

    [self.mm_drawerController  setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture) {
        //was losing reference to weak self. posting notification instead
        [NC postNotificationName:(NSString*)CWMMDrawerCloseNotification object:nil];
    }];
    UIView * spacer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spacer]];
    [NC addObserver:self selector:@selector(handleCWMMDrawerCloseNotification) name:(NSString*)CWMMDrawerCloseNotification object:nil];
    [NC addObserver:self selector:@selector(handleCWMMDrawerOpenNotification:) name:(NSString *)CWNotificationInboxViewControllerShouldOpenInbox object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self rotateBurgerBarAfterDrawAnimation:YES];
}

-(void)dealloc
{
    [NC removeObserver:self name:(NSString*)CWMMDrawerCloseNotification object:nil];
    [NC removeObserver:self name:(NSString*)CWNotificationInboxViewControllerShouldOpenInbox object:nil];
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
        [self rotateBurgerBarAfterDrawAnimation:NO];
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    
    if ([sender isEqual:self.closeButton]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)handleCWMMDrawerCloseNotification
{
    [self rotateBurgerBarAfterDrawAnimation:YES];
}

-(void)handleCWMMDrawerOpenNotification:(NSNotification *)notification {
    
    // Logic is a little bit confusing here - this condition seems to be satisfied (magically?)
    // only when the drawer is closed [RK 031014]
    if (self.mm_drawerController && self.mm_drawerController.visibleLeftDrawerWidth == 0.0f) {
        [self rotateBurgerBarAfterDrawAnimation:NO];
    }

    [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rotateBurgerBarAfterDrawAnimation:(BOOL) isAfterAnimation
{
    MMDrawerController* drawer = self.mm_drawerController;
    CGFloat duration = (drawer.maximumLeftDrawerWidth) / drawer.animationVelocity;

    [UIView animateWithDuration:duration animations:^{

        UIView* burgerView = [self.burgerButton valueForKey:@"view"];
        //Bar Button Items have padding on the right and left sides. this will make it square
        burgerView.bounds = CGRectMake(0, 0, burgerView.bounds.size.width, burgerView.bounds.size.width);
        burgerView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        if(isAfterAnimation ^ (drawer.openSide == MMDrawerSideNone))
        {
            burgerView.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
        }
        else
        {
            burgerView.transform = CGAffineTransformIdentity;
        }
    }];
}
@end
