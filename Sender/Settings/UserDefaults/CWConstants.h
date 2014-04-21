//
//  CWUserDefaultsConstants.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//


/* Notification names */
/* =========================================================================================*/
extern NSString *const CWNotificationInboxViewControllerShouldOpenInbox;
extern NSString *const CWNotificationCopyUpdateFromUrlScheme;
extern NSString *const CWNotificationMessageSent;
extern NSString *const CWNotificationShouldMarkAllMessagesAsRead;
extern NSString *const CWNotificationInboxShouldShowUsersTable;

/* Notification user info keys */
/* =========================================================================================*/
extern NSString *const CWNotificationCopyUpdateFromUrlSchemeUserInfoStartScreenCopyKey;

/*General constants */
/* =========================================================================================*/
extern NSString *const CWConstantsURLSchemeCopyUpdateKey;
extern NSString *const CWConstantsChatwalaAPIKeySecretHeaderField;
extern NSString *const CWConstantsChatwalaAPIKey;
extern NSString *const CWConstantsChatwalaAPISecret;
extern NSString *const CWConstantsChatwalaVersionHeaderField;
extern NSString *const CWConstantsUnknownRecipientIDString;

/* User Defaults */
/* =========================================================================================*/
// This contains NSUserDefault keys used by the defaults controller to persist user settings
extern NSString *const CWUserDefaultsUserIDKey;
extern NSString *const CWUserDefaultsShouldShowPreviewKey;
extern NSString *const CWUserDefaultsNumberOfSentMessagesKey;

// Profile picture
extern NSString *const CWUserDefaultsProfilePictureURLKey;

// User Defaults - Ground Control
extern NSString *const CWConstantsGControlMessagesEndpointKey;

// Message specfici defaults
extern NSString *const CWConstantsMessageMarkedDeletedKey;
extern NSString *const CWUserDefaultsIsFirstOpenKey;