//
//  CWStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWStartScreenViewController.h"
#import "CWVideoManager.h"
#import "CWComposerViewController.h"
#import "CWErrorViewController.h"
#import "CWAuthenticationManager.h"

@interface CWStartScreenViewController ()

@end

@implementation CWStartScreenViewController

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
    [self.navigationController setNavigationBarHidden:YES];

    

    NSError * error = [[[CWVideoManager sharedManager]recorder]setupSession];
    if (error) {
        // handle session error
        CWErrorViewController * vc = [[CWErrorViewController alloc]init];
        [vc setError:error];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [self presentViewController:[[CWAuthenticationManager sharedInstance] requestAuthentication] animated:YES completion:nil];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.startButton];
    
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:self.view.bounds];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.destinationViewController isKindOfClass:[SenderViewController class]]) {
//        SenderViewController * nextVC = (SenderViewController*)segue.destinationViewController;
//        
//    }
//}



//#pragma mark CWVideoRecorderDelegate
//
//- (void)recorder:(CWVideoRecorder *)recorder didFailWithError:(NSError *)error
//{
//    
//}
//
//- (void)recorderRecordingBegan:(CWVideoRecorder *)recorder
//{
//    
//}
//
//- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder
//{
//    
//}


- (IBAction)onStart:(id)sender {
    CWComposerViewController * composerVC = [[CWComposerViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:composerVC animated:NO];
}
@end
