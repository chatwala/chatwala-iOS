//
//  AppDelegate.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenerViewController.h"
#import "SenderViewController.h"
#import "CWPIPOpenerViewController.h"
#import "CWSSOpenerViewController.h"
#import "CWStartScreenViewController.h"
#import "CWSSStartScreenViewController.h"
#import "CWPIPStartScreenViewController.h"


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
    
    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
    
//    UIStoryboard * storyboard;
//    UIViewController * vc;
//    CGFloat screenHeight = SCREEN_BOUNDS.size.height;
//    if (screenHeight> 480) {
//        // iphone5
//        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    }else{
//        // pre-iphone5
//        storyboard = [UIStoryboard storyboardWithName:@"SmallScreen" bundle:[NSBundle mainBundle]];
//    }
    
    CWStartScreenViewController * startVC;
    // = [[CWStartScreenViewController alloc]init];
    
    isSplitScreen = YES;
    
    if (isSplitScreen) {
        startVC = [[CWSSStartScreenViewController alloc]init];
    }else{
        startVC = [[CWPIPStartScreenViewController alloc]init];
    }
    
    self.navController = [[UINavigationController alloc]initWithRootViewController:startVC];

    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
//    vc = [storyboard instantiateInitialViewController];
    
    [self.window addSubview:self.navController.view];
    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    UINavigationController * rootVC = (UINavigationController*)self.window.rootViewController;
    [rootVC popToRootViewControllerAnimated:NO];
//    id currentVC = rootVC.topViewController;
    
//    if ([currentVC isKindOfClass:[SenderViewController class]]) {
//        SenderViewController * vc = (SenderViewController* )currentVC;
//        [vc interruptRecording];
//    }
//    
    
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UINavigationController * rootVC = (UINavigationController*)self.window.rootViewController;
    id currentVC = rootVC.topViewController;
    
    if ([currentVC isKindOfClass:[SenderViewController class]]) {
        SenderViewController * vc = (SenderViewController* )currentVC;
        [vc resumeRecording];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    UINavigationController * rootVC = (UINavigationController*)self.window.rootViewController;
    
    CWOpenerViewController * openerVC;
    if (isSplitScreen) {
        openerVC = [[CWSSOpenerViewController alloc]init];
    }else{
        openerVC = [[CWPIPOpenerViewController alloc]init];
    }
    
    [openerVC setZipURL:url];
    [rootVC pushViewController:openerVC animated:YES];
    
    
    NSLog(@"opener %@",openerVC);
    
    
    return YES;
}




@end
