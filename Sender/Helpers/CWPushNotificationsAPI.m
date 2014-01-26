//
//  CWPushNotificationsAPI.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWPushNotificationsAPI.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"

@implementation CWPushNotificationsAPI

static BOOL didRegisterForPushNotifications = NO;

#pragma mark - Pubic API

+ (void)registerForPushNotifications {

    if (!didRegisterForPushNotifications) {
        // TODO: Use notifications mask
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
}

+ (void)sendProviderDeviceToken:(NSData *)tokenData {
    
    // TODO: add user check here?
    
    NSString *deviceToken = [CWPushNotificationsAPI deviceToken:tokenData];
    
    if ([deviceToken length]) {
        didRegisterForPushNotifications = YES;
    }
    
    // Create new request
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.requestSerializer = [[CWUserManager sharedInstance] requestHeaderSerializer];
    
    __block NSString *userId = nil;
    
    
    
    NSDictionary *params = @{@"user_id" : userId,
                             @"push_token" : deviceToken,
                             @"platform_type" : @"ios"};
    
    [requestManager POST:[[CWMessageManager sharedInstance] registerEndPoint] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully registered push notification token with chatwala server");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to register push notification, error:  %@",error.localizedDescription);
    }];
}

+ (void)handleLocalPushNotification:(UILocalNotification *)notification {
    
}

+ (void)handleRemotePushNotification:(NSDictionary *)userInfo completionBlock:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([userInfo count]) {
        [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUser] withCompletionOrNil:completionHandler];
    }
    else {

    }
}


#pragma mark - Convenience methods

+ (NSString *)deviceToken:(NSData *)tokenData {
    return [CWPushNotificationsAPI deviceTokenAsString:tokenData];
}

+ (NSString *)deviceTokenAsString:(NSData *)token {
    
    NSMutableString *deviceTokenAsString = [[NSMutableString alloc] initWithFormat:@"%@", token];
    
    //TODO: Is this done for us on server side?
    if ([deviceTokenAsString hasPrefix: @"<"]) {
        [deviceTokenAsString deleteCharactersInRange: NSMakeRange(0, 1)];
    }
    
    if ([deviceTokenAsString hasSuffix: @">"]) {
        [deviceTokenAsString deleteCharactersInRange: NSMakeRange([deviceTokenAsString length] - 1, 1)];
    }
    
    
    NSString *trimmed = [deviceTokenAsString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return trimmed;
}


@end
