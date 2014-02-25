//
//  CWUserDefaultsController.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWUserDefaultsController.h"
#import "CWUserDefaultsConstants.h"

@implementation CWUserDefaultsController

+ (void)configureDefaultsIfNecessary {
    
    // Set up these defaults only if the defaults don't already exist. This should allow us to add new defaults in the future without overriding previous, user-defined values.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults valueForKey:CWUserDefaultsShouldShowPreviewKey]) {
        [CWUserDefaultsController setShouldShowMessagePreview:NO];
    }
}

+ (BOOL)shouldShowMessagePreview {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:CWUserDefaultsShouldShowPreviewKey];
}

+ (void)setShouldShowMessagePreview:(BOOL)showMessagePreview {

    [[NSUserDefaults standardUserDefaults] setBool:showMessagePreview forKey:CWUserDefaultsShouldShowPreviewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end