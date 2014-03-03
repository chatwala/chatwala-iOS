//
//  CWUserDefaultsConstants.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWConstants.h"

/* Notification names */
NSString *const CWNotificationInboxViewControllerShouldOpenInbox = @"CWNotificationInboxViewControllerShouldOpenInbox";
NSString *const CWNotificationCopyUpdateFromUrlScheme = @"CWNotificationCopyUpdateFromUrlScheme";

/* Notification user info keys */
NSString *const CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey = @"CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey";

/*General constants */
NSString *const CWConstantsURLSchemeCopyUpdateKey = @"cwcopy";


/* User Defaults */
// Note should be careful changing these values b/c updated users will then lose their defaults

NSString *const CWUserDefaultsUserIDKey = @"CHATWALA_USER_ID";
NSString *const CWUserDefaultsShouldShowPreviewKey = @"CWUserDefaultsShouldShowPreviewKey";