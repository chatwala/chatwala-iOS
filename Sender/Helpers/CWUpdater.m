//
//  CWUpdater.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 5/11/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWUpdater.h"
#import "CWConstants.h"
#import "CWMessageManager.h"

@implementation CWUpdater

- (void)performNecessaryUpdates {

    // If haven't performed 164 updates, then do so
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CWUpdaterPerformed164UpdateKey]) {
        [self performVersion164Updates];
    }
}

- (void)performVersion164Updates {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CWUpdaterPerformed164UpdateKey];
    [[CWMessageManager sharedInstance] clearDiskSpace];
}

@end
