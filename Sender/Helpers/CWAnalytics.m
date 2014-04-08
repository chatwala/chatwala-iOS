//
//  CWAnalytics.m
//  Sender
//
//  Created by Khalid on 11/27/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWAnalytics.h"
#import "CWUserDefaultsController.h"

// Categories
NSString *const CWAnalyticsCategoryFirstOpen = @"FIRST_OPEN";
NSString *const CWAnalyticsCategoryConversationStarter = @"CONVERSATION_STARTER";
NSString *const CWAnalyticsCategoryConversationReplier = @"CONVERSATION_REPLIER";

// Events
NSString *const CWAnalyticsEventAppOpen = @"APP_OPEN";

NSString *const CWAnalyticsEventMicrophoneAccept = @"MICROPHONE_ACCEPT";
NSString *const CWAnalyticsEventMicrophoneDecline = @"MICROPHONE_DECLINE";

NSString *const CWAnalyticsEventMessageFetchingSafari = @"MESSAGE_FETCHING_SAFARI";
NSString *const CWAnalyticsEventMessageFetchedSafari = @"MESSAGE_FETCHED_SAFARI";

NSString *const CWAnalyticsEventMessageOpenedSafari = @"MESSAGE_OPENED_SAFARI";

NSString *const CWAnalyticsEventMessageSentConfirmed = @"MESSAGE_SENT_CONFIRMED";

@implementation CWAnalytics

static NSString *CurrentCategory;

+ (void)calculateCurrentCategory {

     CurrentCategory = ([[CWUserDefaultsController userID] length] ? CWAnalyticsCategoryConversationStarter : CWAnalyticsCategoryFirstOpen);
}

+ (NSString *)currentCategory {

    return CurrentCategory;
}

+ (void)appOpened {
    
    NSString *category = CurrentCategory;
    [CWAnalytics event:CWAnalyticsEventAppOpen withCategory:category withLabel:@"" withValue:nil];
}

+ (void)messageOpenedBySafari:(NSString *)messageID {
    
    NSString *category = ([[CWUserDefaultsController userID] length] ? CWAnalyticsCategoryConversationReplier : CWAnalyticsCategoryFirstOpen);
    [CWAnalytics event:CWAnalyticsEventMessageOpenedSafari withCategory:category withLabel:messageID withValue:nil];
}

+ (void)messageFetchingFromSafari {
    [CWAnalytics event:CWAnalyticsEventMessageFetchingSafari withCategory:CWAnalyticsCategoryFirstOpen withLabel:nil withValue:nil];
}

+ (void)messageFetchedFromSafari:(NSString *)messageID {
    [CWAnalytics event:CWAnalyticsEventMessageFetchedSafari withCategory:CWAnalyticsCategoryFirstOpen withLabel:messageID withValue:nil];
}

+ (void)messageSentWithID:(NSString *)messageID isReply:(BOOL)isReply {
    
    if (![CurrentCategory isEqualToString:CWAnalyticsCategoryFirstOpen]) {
    
        NSString *categoryToUse = (isReply ? CWAnalyticsCategoryConversationReplier : CWAnalyticsCategoryConversationStarter);
        [CWAnalytics event:CWAnalyticsEventMessageSentConfirmed withCategory:categoryToUse withLabel:messageID withValue:nil];
    }
    else {
        
        [CWAnalytics event:CWAnalyticsEventMessageSentConfirmed withCategory:CurrentCategory withLabel:messageID withValue:nil];
    }
    
}

@end