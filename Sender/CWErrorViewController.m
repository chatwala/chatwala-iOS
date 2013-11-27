//
//  CWErrorViewController.m
//  Sender
//
//  Created by Khalid on 11/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWErrorViewController.h"

@interface CWErrorViewController () <UIAlertViewDelegate>

@end

@implementation CWErrorViewController

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

- (IBAction)onGrantAccess:(id)sender {
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                [self onPermissionGranted];
            }else{
                //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];
                [self onPermissionDenied];
            }
        }];
    }
}

- (void)onPermissionGranted
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [CWAnalytics event:@"Microphone Accept" withCategory:@"Onboarding" withLabel:@"" withValue:nil];
}

- (void)onPermissionDenied
{
    [CWAnalytics event:@"Microphone Decline" withCategory:@"Onboarding" withLabel:@"" withValue:nil];
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Microphone" message:@"Please grant access to Microphone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            //
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=USAGE"]];
            break;
            
        default:
            break;
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}
@end
