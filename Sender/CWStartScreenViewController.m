//
//  CWStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWStartScreenViewController.h"
#import "CWVideoManager.h"
#import "CWFlowManager.h"
#import "CWComposerViewController.h"
#import "CWErrorViewController.h"
#import "CWGroundControlManager.h"
#import "AppDelegate.h"
#import "CWLandingViewController.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import "User.h"
#import <UIViewController+MMDrawerController.h>
#import "CWAppFeedBackViewController.h"

@interface CWStartScreenViewController ()
@property (nonatomic,strong) UIImageView * messageSentView;
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
    
    self.messageSentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sent-Notification"]];

    [self.messageSentView setFrame:CGRectMake(0, 8, self.messageSentView.frame.size.width, self.messageSentView.frame.size.height)];
    
    [self.messageSentView setCenter:CGPointMake(160, self.messageSentView.center.y)];
    
    [self.view addSubview:self.messageSentView];
    [self.messageSentView setAlpha:0];
    
    [self.middleButton.button addTarget:self action:@selector(onMiddleButtonTap) forControlEvents:UIControlEventTouchUpInside];

//    NSError * error = [[[CWVideoManager sharedManager]recorder]setupSession];
//    if (error) {
//        // handle session error
//        CWErrorViewController * vc = [[CWErrorViewController alloc]init];
//        [vc setError:error];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    
    [[[CWVideoManager sharedManager]recorder]setupSession];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES];
    [self.startScreenMessageLabel setText:[[CWGroundControlManager sharedInstance] startScreenMessage]];
    
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.startButton];
    
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:self.view.bounds];
    
    if (self.showSentMessage) {
        [UIView animateWithDuration:0.3 animations:^{
            //
            [self.sentMessageView setAlpha:1];
        } completion:^(BOOL finished) {
            //
            [UIView animateWithDuration:0.3 delay:2 options:kNilOptions animations:^{
                //
                [self.sentMessageView setAlpha:0];
            } completion:^(BOOL finished) {
                //
            }];
        }];
        self.showSentMessage = NO;
//        AppDelegate * appdel = (AppDelegate *)[[UIApplication sharedApplication]delegate ];
//
//        [appdel.landingVC setFlowDirection:eFlowToStartScreen];

    }
    /*

    if ([[CWAuthenticationManager sharedInstance]shouldShowAuth]) {
        // not-authenticated
        CWAuthRequestViewController * vc = [[CWAuthRequestViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
     */
    
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"MESSAGE_SENT"]boolValue]) {
        [[NSUserDefaults standardUserDefaults]setValue:@(NO) forKey:@"MESSAGE_SENT"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.messageSentView setAlpha:1];
        __weak CWStartScreenViewController* weakSelf    = self;
        [UIView animateKeyframesWithDuration:0.5 delay:2 options:kNilOptions animations:^{
            //
            [self.messageSentView setAlpha:0];
        } completion:^(BOOL finished) {
            [[CWUserManager sharedInstance] localUser:^(User *localUser) {
                NSInteger outBoxCount = localUser.messagesSent.count;
                NSInteger feedbackTrigger = [[CWGroundControlManager sharedInstance] appFeedbackSentMessageThreshold].integerValue;
                if(![[CWUserManager sharedInstance] appVersionOfAppFeedbackRequest] && (outBoxCount >= feedbackTrigger))
                {
                    [weakSelf showAppFeedback];
                    [[CWUserManager sharedInstance] didRequestAppFeedback];
                }
            }];
        }];
    }else{
        [self.messageSentView setAlpha:0];
    }
}

- (void)onMiddleButtonTap {
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        [SVProgressHUD showErrorWithStatus:@"Internet connection requried\n to send message"];
        return;
    }
    

    [[CWUserManager sharedInstance] localUser:^(User *localUser) {
        [[CWMessageManager sharedInstance] fetchOriginalMessageIDWithSender:localUser completionBlockOrNil:nil];
    }];
    
    [CWAnalytics event:@"START_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    CWComposerViewController * composerVC = [[CWFlowManager sharedInstance]composeVC];
    [self.navigationController pushViewController:composerVC animated:NO];
}

-(void)showAppFeedback
{

    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:[[CWAppFeedBackViewController alloc] init]];

    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    [navController.navigationBar setTintColor:[UIColor whiteColor]];

    [self.mm_drawerController presentViewController:navController animated:YES completion:nil];



}
@end
