//
//  CWUserDefaultsController.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWConstants.h"

@interface CWUserDefaultsController : NSObject

+ (void)configureDefaults;

+ (NSString *)userID;
+ (void)setUserID:(NSString *)userID;

+ (NSURL *)profilePictureReadURL;
+ (void)setProfilePictureReadURL:(NSURL *)readURL;

+ (BOOL)shouldShowMessagePreview;
+ (void)setShouldShowMessagePreview:(BOOL)showMessagePreview;

@end
