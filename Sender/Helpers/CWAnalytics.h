//
//  CWAnalytics.h
//  Sender
//
//  Created by Khalid on 11/27/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "ARAnalytics.h"
#import "ARAnalytics+GoogleAnalytics.h"

// Categories
extern NSString *const CWAnalyticsCategoryFirstOpen;
extern NSString *const CWAnalyticsCategoryConversationStarter;
extern NSString *const CWAnalyticsCategoryConversationReplier;


// Events
extern NSString *const CWAnalyticsEventAppOpen;

extern NSString *const CWAnalyticsEventMicrophoneAccept;
extern NSString *const CWAnalyticsEventMicrophoneDecline;

@interface CWAnalytics : ARAnalytics

@end
