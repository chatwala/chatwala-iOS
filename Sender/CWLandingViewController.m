  //
//  CWLandingViewController.m
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWLandingViewController.h"
#import "CWAuthenticationManager.h"
#import "CWAuthRequestViewController.h"

@interface CWLandingViewController ()

@end

@implementation CWLandingViewController

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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // figure out what to do next!!!
    
    switch (self.flowDirection) {
        case eFlowToStartScreen:
            // start
            
            if ([[CWAuthenticationManager sharedInstance]shouldShowAuth]) {
                // show auth
                [self.navigationController pushViewController:[[CWAuthRequestViewController alloc] init] animated:YES];
            }
            else
            {
                // show start
                CWStartScreenViewController * startScreen = [[CWFlowManager sharedInstance] startScreenVC];
                [self.navigationController pushViewController:startScreen animated:YES];
            }
            
            break;
            
        case eFlowToOpener:
            // opener
            if ([[CWAuthenticationManager sharedInstance]shouldShowAuth]) {
                // show auth
                [self.navigationController pushViewController:[[CWAuthRequestViewController alloc] init] animated:YES];
            }
            else
            {
                // show start
                [self.navigationController pushViewController:[[CWFlowManager sharedInstance] openerVC] animated:YES];
            }
            break;
            
        default:
            break;
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
