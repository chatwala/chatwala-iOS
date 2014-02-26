//
//  CWUserDefaultsController.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

@interface CWUserDefaultsController : NSObject

+ (void)configureDefaults;

+ (BOOL)shouldShowMessagePreview;
+ (void)setShouldShowMessagePreview:(BOOL)showMessagePreview;

@end
