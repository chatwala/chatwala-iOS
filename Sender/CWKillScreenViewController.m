//
//  CWKillScreenViewController.m
//  Sender
//
//  Created by randall chatwala on 1/7/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWKillScreenViewController.h"

@interface CWKillScreenViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textView;

@end

@implementation CWKillScreenViewController

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
    [self.navigationItem setHidesBackButton:YES];
    NSString * const kKillScreenTextKey = @"APP_DISABLED_TEXT";
    self.textView.text = [[NSUserDefaults standardUserDefaults] stringForKey:kKillScreenTextKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
