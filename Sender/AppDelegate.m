//
//  AppDelegate.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "AppDelegate.h"
#import "CWPIPOpenerViewController.h"
#import "CWSSOpenerViewController.h"
#import "CWStartScreenViewController.h"
#import "CWSSStartScreenViewController.h"
#import "CWPIPStartScreenViewController.h"
#import "CWErrorViewController.h"
#import "CWGroundControlManager.h"
#import "CWAuthenticationManager.h"
#import "CWLandingViewController.h"

@interface AppDelegate ()
{
    BOOL isSplitScreen;
}
@property (nonatomic,strong) UINavigationController * navController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [application setStatusBarHidden:YES];
    

    [CWGroundControlManager sharedInstance];
    [CWAuthenticationManager sharedInstance];
    
    
//    [ARAnalytics setupTestFlightWithAppToken:TESTFLIGHT_APP_TOKEN];
    [CWAnalytics setupGoogleAnalyticsWithID:GOOGLE_ANALYTICS_ID];

    
    self.landingVC = [[CWLandingViewController alloc]init];
    [self.landingVC setFlowDirection:eFlowToStartScreen];
    
    self.navController = [[UINavigationController alloc]initWithRootViewController:self.landingVC];

    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    
    [self.window addSubview:self.navController.view];
    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)activateSession
{
    [[[CWVideoManager sharedManager]recorder]resumeSession];
}


- (void)deactivateSession
{
    [[[CWVideoManager sharedManager]recorder]stopSession];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[[CWVideoManager sharedManager]player] stop];
    [[[CWVideoManager sharedManager]recorder]stopSession];
    [[[CWVideoManager sharedManager]recorder]stopVideoRecording];
    
    [self.landingVC setFlowDirection:eFlowToStartScreen];
    [self.navController popToViewController:self.landingVC animated:NO];
//    [self.navController.topViewController.navigationController popToRootViewControllerAnimated:NO];
//    id currentVC = rootVC.topViewController;
    
//    if ([currentVC isKindOfClass:[SenderViewController class]]) {
//        SenderViewController * vc = (SenderViewController* )currentVC;
//        [vc interruptRecording];
//    }
//
    
//    [[CWVideoManager sharedManager]recorder]
    
    [self deactivateSession];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[CWAuthenticationManager sharedInstance]didFinishFirstRun];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self activateSession];
    [[CWGroundControlManager sharedInstance]refresh];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    [ARAnalytics event:@"Open Message" withCategory:@"Message" withLabel:sourceApplication withValue:nil];

    
    [self.landingVC setIncomingMessageZipURL:url];
    [self.landingVC setFlowDirection:eFlowToOpener];
    [self.navController popToRootViewControllerAnimated:NO];
    return YES;
}




@end
