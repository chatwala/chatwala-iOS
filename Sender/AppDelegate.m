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
#import "CWLoadingViewController.h"

#import "CWSettingsViewController.h"





@interface UINavigationBar (customNav)
@end

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,53);
    return newSize;
}
@end

@interface AppDelegate () <CWMenuDelegate>
{
    BOOL isSplitScreen;
    
}
//void (^)(BOOL success, NSURL *url)completionBlock;

@property (nonatomic,strong) CWMenuViewController * menuVC;
@property (nonatomic,strong) CWMainViewController * mainVC;
@property (nonatomic,strong) CWLoadingViewController * loadingVC;
@property (nonatomic,strong) UINavigationController * settingsNavController;
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
    
    [self.menuVC setDelegate:self];
    
    
    self.navController = [[UINavigationController alloc]initWithRootViewController:self.mainVC];
    [self.navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navController.navigationBar.shadowImage = [UIImage new];
    self.navController.navigationBar.translucent = YES;
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];

     
    self.drawController = [[MMDrawerController alloc]initWithCenterViewController:self.navController leftDrawerViewController:self.menuVC];
    [self.drawController setMaximumLeftDrawerWidth:200];
    [self.drawController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView|MMCloseDrawerGestureModeTapCenterView];
    
    
    self.loadingVC = [[CWLoadingViewController alloc]init];
    [self.loadingVC.view setAlpha:0];
//    [self.loadingVC restartAnimation];

    
    [self.drawController.view addSubview:self.loadingVC.view];
    
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    [self.window addSubview:self.drawController.view];
    [self.window setRootViewController:self.drawController];
    [self.window makeKeyAndVisible];
    
    [application setMinimumBackgroundFetchInterval:UIMinimumKeepAliveTimeout];

    
    
    [NC addObserver:self selector:@selector(onMenuButtonTapped) name:MENU_BUTTON_TAPPED object:nil];
    

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
        
        
        NSNumber *previousTotalMessages = [[NSUserDefaults standardUserDefaults] valueForKey:@"MESSAGE_INBOX_COUNT"];
        
        int newMessageCount = [messages count] - [previousTotalMessages intValue];
        if (newMessageCount > 0) {
            [application setApplicationIconBadgeNumber:newMessageCount];
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[messages count]] forKey:@"MESSAGE_INBOX_COUNT"];
        
        completionHandler(UIBackgroundFetchResultNewData);
        [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        NSLog(@"failed to fetch messages with error: %@",error);
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
    
    
    [self.settingsNavController dismissViewControllerAnimated:YES completion:^{
        //
        self.settingsNavController = nil;
    }];
    
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
    
    [application setApplicationIconBadgeNumber:0];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self activateSession];
    
    NSLog(@"server environment: %@",[[CWMessageManager sharedInstance] baseEndPoint]);
    
    [[CWGroundControlManager sharedInstance]refresh];
//    [[CWMessageManager sharedInstance]getMessages];
    
    
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -100)];
        // Check the reachability status and show an alert if the internet connection is not available
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
//                [SVProgressHUD showWithStatus:@"Network not reachable.\nConnection Required."];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
//                [SVProgressHUD dismiss];
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
    NSString * messageId = [[url pathComponents]lastObject];
    
    [self.drawController closeDrawerAnimated:YES completion:nil];
    
    if (self.loadingVC.view.alpha == 0) {
        [self.loadingVC restartAnimation];
        [self.loadingVC.view setAlpha:1];
    }
    

    
    if ([scheme isEqualToString:@"chatwala"]) {
        [[CWMessageManager sharedInstance]downloadMessageWithID:messageId progress:nil completion:^(BOOL success, NSURL *url) {
            // fin
            
            if (success) {
                // loaded message
                [self.openerVC setZipURL:url];
                if ([self.navController.topViewController isEqual:self.openerVC]) {
                    // already showing opener
                }else{
                    [self.navController pushViewController:self.openerVC animated:NO];
                }
                [UIView animateWithDuration:0.5 animations:^{
                    [self.loadingVC.view setAlpha:0];
                }];
            }else{
                // failed to load message
                [self.navController popToRootViewControllerAnimated:NO];
                [UIView animateWithDuration:0.5 animations:^{
                    [self.loadingVC.view setAlpha:0];
                }];
                NSLog(@"failed to download message");
                [SVProgressHUD showErrorWithStatus:@"Message Unavailable"];
            }
            
            
            
            
            

        }];
    }else{
        [self.openerVC setZipURL:url];
        if ([self.navController.topViewController isEqual:self.openerVC]) {
            // already showing opener
        }else{
            [self.navController pushViewController:self.openerVC animated:NO];
        }
        [self.loadingVC.view setAlpha:0];
    }
    [CWAnalytics event:@"Open Message" withCategory:@"Message" withLabel:sourceApplication withValue:nil];
    
    
    /*
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
    
    
    */
    
    
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
//
//- (void)onMessageSent
//{
//    [self.navController.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sent-Notification"]]];
//}

- (UINavigationController *)settingsNavController
{
    if (_settingsNavController==nil) {
        CWSettingsViewController * settings = [[CWSettingsViewController alloc]init];
        _settingsNavController = [[UINavigationController alloc]initWithRootViewController:settings];
        [self.settingsNavController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.settingsNavController.navigationBar.shadowImage = [UIImage new];
        self.settingsNavController.navigationBar.translucent = YES;
        [self.settingsNavController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    
    return _settingsNavController;
}


#pragma mark CWMenuDelegate

- (void)menuViewController:(CWMenuViewController *)menuVC didSelectButton:(UIButton *)button
{
    [self.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
        if ([button isEqual:menuVC.plusButton]) {
            // check if showing start screen
            if ([self.mainVC.navigationController.visibleViewController isKindOfClass:[CWStartScreenViewController class]]) {
                // do nothing
            }else{
                [self.mainVC.navigationController popToRootViewControllerAnimated:NO];
            }
        }
        else if ([button isEqual:menuVC.settingsButton])
        {
            
            
            
            
            
            
            
            [self.drawController presentViewController:self.settingsNavController animated:YES completion:^{
                //
            }];
        }
    }];
    
    
    
}


- (void)menuViewController:(CWMenuViewController *)menuVC didSelectMessageWithID:(NSString *)messageId
{
    
    AppDelegate * appdel = self;
    [self.drawController closeDrawerAnimated:YES completion:nil];
    [self.loadingVC restartAnimation];
    [self.loadingVC.view setAlpha:1];
    
    
    
    
    [[CWMessageManager sharedInstance]downloadMessageWithID:messageId  progress:nil completion:^(BOOL success, NSURL *url) {
        //
        if (success) {
            [appdel application:[UIApplication sharedApplication] openURL:url sourceApplication:nil annotation:nil];
        }else{
            // fail
            [self.navController popToRootViewControllerAnimated:NO];
            [UIView animateWithDuration:0.5 animations:^{
                [self.loadingVC.view setAlpha:0];
            }];
            [SVProgressHUD showErrorWithStatus:@"Message Unavailable"];
            NSLog(@"failed to download message");
        }
        

    }];

}

@end
