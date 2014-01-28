//
//  CWPushNotificationsAPI.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWPushNotificationsAPI : NSObject


// Set up used by App Delegate
+ (void)registerForPushNotifications;
+ (void)sendProviderDeviceToken:(NSData *)tokenData;

// Inbound notifications
+ (void)handleLocalPushNotification:(UILocalNotification *)notification;
+ (void)handleRemotePushNotification:(NSDictionary *)userInfo completionBlock:(void (^)(UIBackgroundFetchResult))completionHandler;
@end
