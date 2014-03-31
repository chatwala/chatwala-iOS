//
//  CWUserDefaultsConstants.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWConstants.h"

/* Notification names */
/* =========================================================================================*/
NSString *const CWNotificationInboxViewControllerShouldOpenInbox = @"CWNotificationInboxViewControllerShouldOpenInbox";
NSString *const CWNotificationCopyUpdateFromUrlScheme = @"CWNotificationCopyUpdateFromUrlScheme";
NSString *const CWNotificationMessageSent = @"CWNotificationMessageSent";

/* Notification user info keys */
/* =========================================================================================*/
NSString *const CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey = @"CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey";

/*General constants */
/* =========================================================================================*/
NSString *const CWConstantsURLSchemeCopyUpdateKey = @"cwcopy";
NSString *const CWConstantsChatwalaAPIKeySecretHeaderField = @"x-chatwala";
NSString *const CWConstantsChatwalaAPIKey = @"58041de0bc854d9eb514d2f22d50ad4c";
NSString *const CWConstantsChatwalaAPISecret = @"ac168ea53c514cbab949a80bebe09a8a";
NSString *const CWConstantsUnknownRecipientIDString = @"RECIPIENT_UNKNOWN";

/* User Defaults */
// Note should be careful changing these values b/c updated users will then lose their defaults
/* =========================================================================================*/
NSString *const CWUserDefaultsUserIDKey = @"CHATWALA_USER_ID";
NSString *const CWUserDefaultsShouldShowPreviewKey = @"CWUserDefaultsShouldShowPreviewKey";
NSString *const CWUserDefaultsNumberOfSentMessagesKey = @"CWUserDefaultsNumberOfSentMessagesKey";
// Profile picture
NSString *const CWUserDefaultsProfilePictureURLKey = @"CWUserDefaultsProfilePictureURLKey";

// User Defaults - Ground Control
NSString *const CWConstantsGControlMessagesEndpointKey = @"GC_MESSAGES_ENDPOINT";
