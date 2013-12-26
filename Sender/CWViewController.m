//
//  CWViewController.m
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWViewController.h"

@interface CWViewController ()

@property (nonatomic,strong) UIBarButtonItem * burgerButton;
@property (nonatomic,strong) UIBarButtonItem * closeButton;
@property (nonatomic,strong) UIImageView * messageSentView;
@end

@implementation CWViewController

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
    self.burgerButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(onTap:)];
    self.closeButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Close-Button"] style:UIBarButtonItemStylePlain target:self action:@selector(onTap:)];
    self.messageSentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sent-Notification"]];
    [self.messageSentView setFrame:CGRectMake(0, 0, 80, 50)];
    [self.messageSentView setAlpha:0];
    [self.navigationItem setTitleView:self.messageSentView];
    
    UIView * spacer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spacer]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.messageSentView setAlpha:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"MESSAGE_SENT"]boolValue]) {
        [[NSUserDefaults standardUserDefaults]setValue:@(NO) forKey:@"MESSAGE_SENT"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.messageSentView setAlpha:1];
        [UIView animateKeyframesWithDuration:0.5 delay:2 options:kNilOptions animations:^{
            //
            [self.messageSentView setAlpha:0];
        } completion:^(BOOL finished) {
            //
        }];
    }else{
        [self.messageSentView setAlpha:0];
    }
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
    if ([sender isEqual:self.burgerButton]) {
        [NC postNotificationName:MENU_BUTTON_TAPPED object:nil];
    }
    
    if ([sender isEqual:self.closeButton]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
