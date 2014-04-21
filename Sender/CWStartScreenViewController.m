//
//  CWStartScreenViewController.m
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWStartScreenViewController.h"
#import "CWVideoManager.h"
#import "CWSSComposerViewController.h"
#import "CWErrorViewController.h"
#import "CWGroundControlManager.h"
#import "AppDelegate.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import <UIViewController+MMDrawerController.h>
#import "CWAppFeedBackViewController.h"
#import "CWAnalytics.h"
#import "CWProfilePictureViewController.h"
#import "CWConstants.h"
#import "CWVideoFileCache.h"

@interface CWStartScreenViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIImageView * messageSentView;
@property (nonatomic) UIViewController * popupModal;

@property (nonatomic,assign) BOOL shouldUseBackCamera;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation CWStartScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [self.popupModal dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CWNotificationCopyUpdateFromUrlScheme object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    self.messageSentView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sent-Notification"]];
    [self.messageSentView setFrame:CGRectMake(0, 8, self.messageSentView.frame.size.width, self.messageSentView.frame.size.height)];
    [self.messageSentView setCenter:CGPointMake(160, self.messageSentView.center.y)];
    
    [self.view addSubview:self.messageSentView];
    [self.messageSentView setAlpha:0];
    
    [self.middleButton.button addTarget:self action:@selector(onMiddleButtonTap) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CWVideoManager sharedManager] recorder] setupSessionWithBackCamera:self.shouldUseBackCamera];
    
    // single tap gesture recognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggledCamera:)];
    [self.tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyUpdated:) name:CWNotificationCopyUpdateFromUrlScheme object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[[[CWVideoManager sharedManager] recorder] recorderView] setAlpha:1.0f];
    [self.startScreenMessageLabel setText:[[CWGroundControlManager sharedInstance] startScreenMessage]];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    [[[CWVideoManager sharedManager] recorder] checkForMicAccess];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.startButton];
    
    [[[[CWVideoManager sharedManager] recorder] recorderView] setFrame:self.view.bounds];
    
    if (self.showSentMessage) {
        [UIView animateWithDuration:0.3 animations:^{
            //
            [self.sentMessageView setAlpha:1];
        } completion:^(BOOL finished) {
            //
            [UIView animateWithDuration:0.3f delay:2.0f options:kNilOptions animations:^{
                //
                [self.sentMessageView setAlpha:0];
            } completion:^(BOOL finished) {
                //
            }];
        }];
        self.showSentMessage = NO;
    }
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"MESSAGE_SENT"]boolValue]) {
        [[NSUserDefaults standardUserDefaults]setValue:@(NO) forKey:@"MESSAGE_SENT"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.messageSentView setAlpha:1];
        __weak CWStartScreenViewController* weakSelf    = self;
        [UIView animateKeyframesWithDuration:0.5 delay:2 options:kNilOptions animations:^{
            //
            [self.messageSentView setAlpha:0];

        } completion:nil];
        

        if(![[CWUserManager sharedInstance] hasApprovedProfilePicture:[[CWUserManager sharedInstance] localUserID]])
        {
            //show the profile picture
            [self showProfilePictureWasUploaded];
        }
        else if([[CWUserManager sharedInstance] shouldRequestAppFeedback])
        {
            //ask for app feedback
            [weakSelf showAppFeedback];
            [[CWUserManager sharedInstance] didRequestAppFeedback];
        }

    }else{
        [self.messageSentView setAlpha:0];
    }
}

- (void)onMiddleButtonTap {
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        [SVProgressHUD showErrorWithStatus:@"Internet connection required\n to send message."];
        return;
    }
    else if (![[CWVideoFileCache sharedCache] hasMinimumFreeDiskSpace])  {
        [SVProgressHUD showErrorWithStatus:@"Please free up disk space! Unable to record new message."];
        return;
    }
    
    // Pre-emptively fetch upload URL so we don't have any delay for original message delivery modal
    [[CWMessageManager sharedInstance] fetchUploadURLForOriginalMessage:[[CWUserManager sharedInstance] localUserID] completionBlockOrNil:nil];
    
    [CWAnalytics event:@"START_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    CWComposerViewController * composerVC = [[CWSSComposerViewController alloc] init];
    [self.navigationController pushViewController:composerVC animated:NO];
}

- (void)showProfilePictureWasUploaded {
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:[[CWProfilePictureViewController alloc] init]];
    
    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    [navController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.mm_drawerController presentViewController:navController animated:YES completion:nil];
    
    self.popupModal = navController;
}

-(void)showAppFeedback {
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:[[CWAppFeedBackViewController alloc] init]];

    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    [navController.navigationBar setTintColor:[UIColor whiteColor]];

    [self.mm_drawerController presentViewController:navController animated:YES completion:nil];

    self.popupModal = navController;

}

#pragma mark - Notification handlers

- (void)copyUpdated:(NSNotification *) notification {
    
    NSDictionary* userInfo = notification.userInfo;
    self.startScreenMessageLabel.text = [userInfo objectForKey:CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey];
    NSLog (@"Updated start screen text from notification");
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGPoint pointInView = [touch locationInView:gestureRecognizer.view];
    
    if ([gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]
        && CGRectContainsPoint(CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height * 0.5f), pointInView) ) {
        
        if (!CGRectContainsPoint(self.startButton.frame, pointInView)) {
            return YES;
        }
    }
    
    return NO;
}

- (void)toggledCamera:(UIGestureRecognizer *)recognizer {
    
    NSLog(@"Record screen tapped from start screen");
    self.shouldUseBackCamera = !self.shouldUseBackCamera;
    
     AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:(self.shouldUseBackCamera ? [CWVideoRecorder backFacingCamera] : [CWVideoRecorder frontFacingCamera]) error:nil];
    [[[CWVideoManager sharedManager] recorder] changeVideoInput:videoInput];
}

@end
