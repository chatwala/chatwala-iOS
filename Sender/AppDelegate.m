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
#import "CWUserManager.h"
#import "CWMenuViewController.h"
#import "CWMainViewController.h"
#import "CWMessageManager.h"


@interface UINavigationBar (customNav)
@end

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,50);
    return newSize;
}
@end

@interface AppDelegate ()
{
    BOOL isSplitScreen;
}
@property (nonatomic,strong) CWMenuViewController * menuVC;
@property (nonatomic,strong) CWMainViewController * mainVC;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [application setStatusBarHidden:YES];
    
    [CWUserManager sharedInstance];

    [CWGroundControlManager sharedInstance];
    [CWAuthenticationManager sharedInstance];
    

    
    [ARAnalytics setupTestFlightWithAppToken:TESTFLIGHT_APP_TOKEN];
    [CWAnalytics setupGoogleAnalyticsWithID:GOOGLE_ANALYTICS_ID];
    
    [[NSUserDefaults standardUserDefaults]setValue:@(NO) forKey:@"MESSAGE_SENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    self.menuVC = [[CWMenuViewController alloc]init];
    self.mainVC = [[CWMainViewController alloc]init];
    
//    self.landingVC = [[CWLandingViewController alloc]init];
//    [self.landingVC setFlowDirection:eFlowToStartScreen];
//
    
    
    self.navController = [[UINavigationController alloc]initWithRootViewController:self.mainVC];
    [self.navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navController.navigationBar.shadowImage = [UIImage new];
    self.navController.navigationBar.translucent = YES;
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];

     
    self.drawController = [[MMDrawerController alloc]initWithCenterViewController:self.navController leftDrawerViewController:self.menuVC];
    [self.drawController setMaximumLeftDrawerWidth:200];
    [self.drawController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];
    
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    [self.window addSubview:self.drawController.view];
    [self.window setRootViewController:self.drawController];
    [self.window makeKeyAndVisible];
    
    [application setMinimumBackgroundFetchInterval:UIMinimumKeepAliveTimeout];

    
    
    [NC addObserver:self selector:@selector(onMenuButtonTapped) name:MENU_BUTTON_TAPPED object:nil];
    [NC addObserver:self selector:@selector(onMessageSent) name:@"message_sent" object:nil];
    

    /*
    self.landingVC = [[CWLandingViewController alloc]init];
    [self.landingVC setFlowDirection:eFlowToStartScreen];
    
    self.navController = [[UINavigationController alloc]initWithRootViewController:self.landingVC];

    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    
    [self.window addSubview:self.navController.view];
    [self.window setRootViewController:self.navController];
    [self.window makeKeyAndVisible];
    
    [application setMinimumBackgroundFetchInterval:UIMinimumKeepAliveTimeout];
    */
    
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * url = [NSString stringWithFormat:[[CWMessageManager sharedInstance] getUserMessagesEndPoint],user_id] ;
    NSLog(@"fetching messages: %@",url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSLog(@"fetched user messages: %@",responseObject);
        NSArray * messages = [responseObject objectForKey:@"messages"];
        [application setApplicationIconBadgeNumber:messages.count];
        completionHandler(UIBackgroundFetchResultNewData);
        [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        NSLog(@"failed to fecth messages");
        completionHandler(UIBackgroundFetchResultNoData);
        [NC postNotificationName:@"MessagesLoadFailed" object:nil userInfo:nil];
    }];
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
    
//    [self.landingVC setFlowDirection:eFlowToStartScreen];
    [self.navController popToRootViewControllerAnimated:NO];
//    [self.navController.topViewController.navigationController popToRootViewControllerAnimated:NO];
//    id currentVC = rootVC.topViewController;
    
//    if ([currentVC isKindOfClass:[SenderViewController class]]) {
//        SenderViewController * vc = (SenderViewController* )currentVC;
//        [vc interruptRecording];
//    }
//
    
//    [[CWVideoManager sharedManager]recorder]
    
    [self deactivateSession];
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
    
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
    
    NSLog(@"server environment: %@",[[CWMessageManager sharedInstance] baseEndPoint]);
    
    [[CWGroundControlManager sharedInstance]refresh];
    
    
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -100)];
        // Check the reachability status and show an alert if the internet connection is not available
        switch (status) {
            case -1:
                // AFNetworkReachabilityStatusUnknown = -1,
                NSLog(@"The reachability status is Unknown");
                
                [SVProgressHUD showWithStatus:@"Network not reachable.\nConnection Required."];
                break;
            case 0:
                // AFNetworkReachabilityStatusNotReachable = 0
                NSLog(@"The reachability status is not reachable");
                [SVProgressHUD showWithStatus:@"Network not reachable.\nConnection Required."];
                break;
            case 1:
                // AFNetworkReachabilityStatusReachableViaWWAN = 1
                NSLog(@"The reachability status is reachable via WWAN");
                [SVProgressHUD dismiss];
                break;
            case 2:
                // AFNetworkReachabilityStatusReachableViaWiFi = 2
                NSLog(@"The reachability status is reachable via WiFi");
                [SVProgressHUD dismiss];
                break;
                
            default:
                break;
        }
        
    }];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"opening URL...");
    NSString * scheme = [url scheme];
  
    if ([scheme isEqualToString:@"chatwala"]) {
        // open remote message
        
        NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[[[url pathComponents] objectAtIndex:1] stringByAppendingString:@".zip"]];
    
        if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            // already downloaded
            
            [self.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
                [self application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:localPath] sourceApplication:nil annotation:nil];
            }];
            
        }else{
        
            NSString * messagePath =[NSString stringWithFormat:[[CWMessageManager sharedInstance] getMessageEndPoint],[[url pathComponents] objectAtIndex:1]];
    //        [SUBMIT_MESSAGE_ENDPOINT stringByAppendingPathComponent:[[url pathComponents] objectAtIndex:1]];
            
            NSLog(@"downloading file at: %@",messagePath);
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURL *URL = [NSURL URLWithString:messagePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
                
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if(error)
                {
                    NSLog(@"error %@", error);
                }
                else
                {
                    NSLog(@"File downloaded to: %@", filePath);
                    [self.openerVC setZipURL:filePath];
                    [self.navController pushViewController:self.openerVC animated:NO];
                    
    //                [self.landingVC setIncomingMessageZipURL:filePath];
    //                [self.landingVC setFlowDirection:eFlowToOpener];
    //                [self.navController popToRootViewControllerAnimated:NO];
                }
            }];
            [downloadTask resume];
        
        }
    }else{
        [CWAnalytics event:@"Open Message" withCategory:@"Message" withLabel:sourceApplication withValue:nil];
//        [self.landingVC setIncomingMessageZipURL:url];
//        [self.landingVC setFlowDirection:eFlowToOpener];
        [self.openerVC setZipURL:url];
        if ([self.navController.topViewController isEqual:self.openerVC]) {
            // already showing opener
        }else{
            [self.navController pushViewController:self.openerVC animated:NO];
        }
        
    }
    
    

    
    
    return YES;
}


- (CWSSOpenerViewController *)openerVC
{
    if (_openerVC == nil) {
        _openerVC = [[CWSSOpenerViewController alloc]init];
    }
    
    return _openerVC;
}


- (void)onMenuButtonTapped
{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        return;
    }
    
    if (self.drawController.openSide == MMDrawerSideNone) {
        [[self drawController]openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
            //
        }];
    }else{
        [[self drawController]closeDrawerAnimated:YES completion:^(BOOL finished) {
            //
        }];
    }
}

- (void)onMessageSent
{
    [self.navController.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sent-Notification"]]];
}

@end
