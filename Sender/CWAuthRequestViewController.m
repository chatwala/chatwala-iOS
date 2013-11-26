//
//  CWAuthRequestViewController.m
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWAuthRequestViewController.h"
#import "CWAuthenticationManager.h"
#import "CWEmailSignupViewController.h"

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
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onAuthenticate:(id)sender {
    [ARAnalytics event:@"Choose Google Authentication" withCategory:@"Onboarding" withLabel:@"" withValue:nil];
    [self.navigationController pushViewController:[[CWAuthenticationManager sharedInstance] requestAuthentication] animated:YES];
}


- (void)handleBack:(id)sender
{
    [ARAnalytics event:@"Skip Authentication" withCategory:@"Onboarding" withLabel:@"" withValue:nil];
    [[CWAuthenticationManager sharedInstance]didSkipAuth];
    [self.navigationController popViewControllerAnimated:NO];
}


- (IBAction)onUseEmail:(id)sender {
    [ARAnalytics event:@"Choose Email Authentication" withCategory:@"Onboarding" withLabel:@"" withValue:nil];
    CWEmailSignupViewController * vc = [[CWEmailSignupViewController alloc]init];
    [self.navigationController pushViewController:vc animated:NO];
}
@end
