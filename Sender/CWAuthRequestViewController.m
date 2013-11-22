//
//  CWAuthRequestViewController.m
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWAuthRequestViewController.h"
#import "CWAuthenticationManager.h"

@interface CWAuthRequestViewController ()

@end

@implementation CWAuthRequestViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onAuthenticate:(id)sender {
    [self presentViewController:[[CWAuthenticationManager sharedInstance] requestAuthentication] animated:NO completion:nil];
}

- (IBAction)onSkip:(id)sender
{
    [[CWAuthenticationManager sharedInstance]didSkipAuth];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
