//
//  AppDelegate.m
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "AppDelegate.h"
#import "CWGroundControlManager.h"
#import "CWUserManager.h"
#import "CWMainViewController.h"
#import "CWMessageManager.h"
#import "CWLoadingViewController.h"
#import "CWSettingsViewController.h"
#import "CWDataManager.h"
#import "CWPushNotificationsAPI.h"
#import "CWMessagesDownloader.h"
#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FacebookSDK.h> 
#import "CWUserDefaultsController.h"
#import "CWStartScreenViewController.h"
#import "CWVideoFileCache.h"
#import "CWInboxViewController.h"


#define MAX_LEFT_DRAWER_WIDTH 131
#define DRAWER_OPENING_VELOCITY 250.0

NSString* const CWMMDrawerCloseNotification = @"CWMMDrawerCloseNotification";

@interface UINavigationBar (customNav)
@end

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,53);
    return newSize;
}
@end

@interface AppDelegate () <CWInboxDelegate>


@property (nonatomic,strong) CWInboxViewController * inboxController;
@property (nonatomic,strong) CWMainViewController * mainVC;
@property (nonatomic,strong) CWLoadingViewController * loadingVC;
@property (nonatomic,strong) UINavigationController * settingsNavController;
@property (nonatomic,assign) BOOL fetchingFirstLaunchMessage;

@end


@implementation AppDelegate

#pragma mark - Application lifecycle methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    [CWUserDefaultsController configureDefaults];
    [Crashlytics sharedInstance];
    [Crashlytics startWithAPIKey:CRASHLYTICS_API_TOKEN];
    
    // Override point for customization after application launch.
    [application setStatusBarHidden:YES];

    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[CWDataManager sharedInstance] setupCoreData];
    
#ifdef USE_QA_SERVER
    NSString *analyticsID = @"UA-46207837-4";
    NSString *messageRetrievalEndpoint = @"http://chatwala.com/qa/fetch_messages.html";
#elif USE_DEV_SERVER
    NSString *analyticsID = @"UA-46207837-3";
    NSString *messageRetrievalEndpoint = @"http://chatwala.com/dev/fetch_messages.html";
#elif USE_SANDBOX_SERVER
    NSString *analyticsID = @"UA-46207837-3";
    NSString *messageRetrievalEndpoint = @"http://chatwala.com/dev/fetch_messages.html";
#elif USE_STAGING_SERVER
    NSString *analyticsID = @"UA-46207837-5";
    NSString *messageRetrievalEndpoint = @"http://chatwala.com/fetch_messages.html";
#else
    NSString *analyticsID = @"UA-46207837-1";
    NSString *messageRetrievalEndpoint = @"http://chatwala.com/fetch_messages.html";
#endif
    
    [CWAnalytics setupGoogleAnalyticsWithID:analyticsID];
    [CWAnalytics appOpened];
    
    if(![[CWUserDefaultsController userID] length]) {
        [self fetchMessageFromURLString:messageRetrievalEndpoint];
    }
    
    [CWUserManager sharedInstance];
    [CWGroundControlManager sharedInstance];
    
    [[NSUserDefaults standardUserDefaults]setValue:@(NO) forKey:@"MESSAGE_SENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    self.inboxController = [[CWInboxViewController alloc]init];
    self.mainVC = [[CWMainViewController alloc]init];

    [self.inboxController setDelegate:self];
    
    
    self.navController = [[UINavigationController alloc]initWithRootViewController:self.mainVC];
    [self.navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navController.navigationBar.shadowImage = [UIImage new];
    self.navController.navigationBar.translucent = YES;
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];

     
    self.drawController = [[MMDrawerController alloc]initWithCenterViewController:self.navController leftDrawerViewController:self.inboxController];
    [self.drawController setMaximumLeftDrawerWidth:MAX_LEFT_DRAWER_WIDTH];
    [self.drawController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];

    self.loadingVC = [[CWLoadingViewController alloc]init];
    [self.loadingVC.view setAlpha:0];
    
    [self.drawController.view addSubview:self.loadingVC.view];
    
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    [self.window addSubview:self.drawController.view];
    [self.window setRootViewController:self.drawController];
    [self.window makeKeyAndVisible];
    
    [application setMinimumBackgroundFetchInterval:UIMinimumKeepAliveTimeout];
    
    NSDictionary *remoteNotificationDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationDictionary) {
        // The app isn't being awakened from terminated state - for now just logging that we received this.
        NSLog(@"Received remote notifcation callback in didFinishLaunchingWithOptions %@", remoteNotificationDictionary);
    }

    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUserID] withCompletionOrNil:completionHandler];
}

- (void)applicationWillResignActive:(UIApplication *)application {
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[CWAuthenticationManager sharedInstance]didFinishFirstRun];
    
    //  Update badge so the user sees valid information
    if( [[CWUserManager sharedInstance] localUserID]) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[CWUserManager sharedInstance] numberOfUnreadMessages]];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSString * fbAppID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    
#ifdef USE_QA_SERVER
    fbAppID = @"639218822814074";
#elif USE_DEV_SERVER
    fbAppID = @"1472279299660540";
#elif USE_SANDBOX_SERVER
    fbAppID = @"1472279299660540";
#endif
    
    [FBSettings setDefaultAppID:fbAppID];
    [FBAppEvents activateApp];
    
    if( [[CWUserManager sharedInstance] localUserID]) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[CWUserManager sharedInstance]numberOfUnreadMessages]];
    }
    else {
        [application setApplicationIconBadgeNumber:0];
    }
    
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
            case AFNetworkReachabilityStatusNotReachable:
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                break;
                
            default:
                break;
        }
    }];
    
    // Fetch a new message upload ID from server
    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUserID] withCompletionOrNil:nil];
    //[[CWMessageManager sharedInstance] fetchOriginalMessageIDWithSender:[[CWUserManager sharedInstance] localUser] completionBlockOrNil:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
   
    // Check to see if this is just a copy update & get out of here.
    if ([self isCopyUpdate:url]) {
        [self updateCopyForStartScreen:url];
        return YES;
    }
   
    NSString * scheme = [url scheme];
    NSString * downloadID = [[url pathComponents] lastObject];
    NSString *messageID = [[downloadID componentsSeparatedByString:@"."] lastObject];
    
    [self.drawController closeDrawerAnimated:YES completion:nil];
    
    if (![downloadID length] || ![messageID length]) {
        return YES;
    }
    
    if (self.loadingVC.view.alpha == 0) {
        [self.loadingVC restartAnimation];
        [self.loadingVC.view setAlpha:1];
    }


#ifdef USE_DEV_SERVER
    NSString *appURLScheme = @"chatwala-dev";
#elif USE_QA_SERVER
    NSString *appURLScheme = @"chatwala-qa";
#elif USE_SANDBOX_SERVER
    NSString *appURLScheme = @"chatwala-sandbox";
#else
    NSString *appURLScheme = @"chatwala";
#endif
    
    if ([scheme isEqualToString:appURLScheme]) {
        
        NSURL *urlToOpen = [NSURL URLWithString:[[CWVideoFileCache sharedCache] filepathForKey:messageID]];
        
        if (!urlToOpen) {
            CWMessagesDownloader *downloader = [[CWMessagesDownloader alloc] init];
            
            NSString *messageDownloadEndpoint = [CWMessagesDownloader messageEndpointFromSMSDownloadID:downloadID];
            
            [downloader downloadMessageFromEndpoint:messageDownloadEndpoint completion:^(BOOL success, NSURL *url) {
                if (success && url) {
                    
                    // TODO:  This code is duplicated further down this snippet
                    [self.openerVC setZipURL:url];
                    if ([self.navController.topViewController isEqual:self.openerVC]) {
                        // already showing opener
                    }
                    else {
                        [self.navController pushViewController:self.openerVC animated:NO];
                    }
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        [self.loadingVC.view setAlpha:0];
                    }];
                }
                else {
                    [self.navController popToRootViewControllerAnimated:NO];
                    [UIView animateWithDuration:0.5 animations:^{
                        [self.loadingVC.view setAlpha:0];
                    }];
                    NSLog(@"failed to download message");
                    [SVProgressHUD showErrorWithStatus:@"Message not available yet."];
                }
            }];
        }
        else {
            [self loadOpenerWithURL:urlToOpen];
        }
    }
    else {
        [self loadOpenerWithURL:url];
    }

    [self sendMessageOpenTrackingWithMessageID:messageID];
    return YES;
}

#pragma mark - URL Scheme based copy updates

- (BOOL)isCopyUpdate:(NSURL *)url {
    
    if ([[url absoluteString] rangeOfString:CWConstantsURLSchemeCopyUpdateKey].location == NSNotFound) {
        return NO;
    }
    else{
        return YES;
    }
}

- (void)updateCopyForStartScreen:(NSURL *)url {
    
    NSString *copyParameter = [[url pathComponents] lastObject];
    
    if ([copyParameter length]) {
        
        NSString *newCopy = [copyParameter stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        newCopy = [NSString stringWithFormat:@"%@.", newCopy];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:newCopy forKey:CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CWNotificationCopyUpdateFromUrlScheme object:self userInfo:userInfo];
    }
    
}

#pragma mark - Message opening

- (void)sendMessageOpenTrackingWithMessageID:(NSString *)messageID {
    
    if (self.fetchingFirstLaunchMessage) {
        [CWAnalytics messageFetchedSafari:messageID];
    }
    else {
        [CWAnalytics messageOpenSafari:messageID];
    }
    
    self.fetchingFirstLaunchMessage = NO;
}

- (void)fetchMessageFromURLString:(NSString *)urlString {
    
    // Create new request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.fetchingFirstLaunchMessage = YES;
        [CWAnalytics messageFetchingSafari];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed to fetch picture upload ID from the server for a reply with error:%@",error);
    }];
    
}

- (void)loadOpenerWithURL:(NSURL *)messageLocalURL {
    [self.openerVC setZipURL:messageLocalURL];
    if ([self.navController.topViewController isEqual:self.openerVC]) {
        // already showing opener
    }
    else {
        [self.navController pushViewController:self.openerVC animated:NO];
    }
    
    [self.loadingVC.view setAlpha:0];
}

#pragma mark - Video recorder session management

- (void)activateSession {
    [[[CWVideoManager sharedManager]recorder]resumeSession];
}

- (void)deactivateSession {
    [[[CWVideoManager sharedManager]recorder]stopSession];
}


- (CWSSOpenerViewController *)openerVC {
    if (_openerVC == nil) {
        _openerVC = [[CWSSOpenerViewController alloc]init];
    }
    
    return _openerVC;
}

- (UINavigationController *)settingsNavController {
    
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

-(void)sendDrawerCloseNotification {
    [NC postNotificationName:(NSString *)CWMMDrawerCloseNotification object:nil];
}

#pragma mark - CWInboxDelegate

- (void)inboxViewController:(CWInboxViewController *)inboxVC didSelectSettingsButton:(UIButton *)button {
    [self.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
        if ([button isEqual:inboxVC.settingsButton]) {
            [self.drawController presentViewController:self.settingsNavController animated:YES completion:nil];
        }
        
        [self sendDrawerCloseNotification];
    }];

}

- (void)inboxViewController:(CWInboxViewController *)inboxVC didSelectTopButton:(UIButton *)button {
    [self.drawController closeDrawerAnimated:YES completion:^(BOOL finished) {
        if ([button isEqual:inboxVC.plusButton]) {
            // check if showing start screen
            if ([self.mainVC.navigationController.visibleViewController isKindOfClass:[CWStartScreenViewController class]]) {
                // do nothing
            }else{
                [self.mainVC.navigationController popToRootViewControllerAnimated:NO];
            }
        }
        [self sendDrawerCloseNotification];
    }];
}

- (void)inboxViewController:(CWInboxViewController *)inboxVC didSelectMessage:(Message *)message {
    
    AppDelegate * appdel = self;
    __weak AppDelegate* weakSelf = self;
    [self.drawController closeDrawerAnimated:YES completion:^(BOOL finished){
        [weakSelf sendDrawerCloseNotification];
    }];
    [self.loadingVC restartAnimation];
    [self.loadingVC.view setAlpha:1];
    
    
    NSURL *urlToOpen = [NSURL URLWithString:[[CWVideoFileCache sharedCache] filepathForKey:message.messageID]];
    
    if (!urlToOpen) {
    
        CWMessagesDownloader *downloader = [[CWMessagesDownloader alloc] init];
        [downloader downloadMessageFromEndpoint:message.readURL completion:^(BOOL success, NSURL *url) {
           
            if (success && url) {
                // loaded message
                [appdel application:[UIApplication sharedApplication] openURL:url sourceApplication:nil annotation:nil];
            }
            else {
                // fail
                [self.navController popToRootViewControllerAnimated:NO];
                [UIView animateWithDuration:0.5 animations:^{
                    [self.loadingVC.view setAlpha:0];
                }];
                [SVProgressHUD showErrorWithStatus:@"Message unavailable."];
                NSLog(@"failed to download message");
            }
            
        }];
    }
    else {
        [appdel application:[UIApplication sharedApplication] openURL:urlToOpen sourceApplication:nil annotation:nil];
    }
}

#pragma mark - Push Notification Registration delegate methods

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    [CWPushNotificationsAPI sendProviderDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in notifications registration. Error: %@", err);
}

#pragma mark - Push Notification Receive delegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [CWPushNotificationsAPI handleLocalPushNotification:notification];
    
}

// This called whenever a remote-push notification is received - even if the app is not running
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [CWPushNotificationsAPI handleRemotePushNotification:userInfo completionBlock:completionHandler];
}

@end
