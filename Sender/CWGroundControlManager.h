//
//  CWGroundControlManager.h
//  Sender
//
//  Created by Khalid on 11/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^ RefreshGroundControlSuccessBlock)(NSDictionary * defaults);
typedef void (^ RefreshGroundControlFailureBlock)(NSError * failure);

@interface CWGroundControlManager : NSObject
+(instancetype) sharedInstance;
- (NSString*)tapToPlayVideo;
- (NSString*)feedbackRecordingString;
- (NSString*)feedbackResponseString;
- (NSString*)feedbackReactionString;
- (NSString*)feedbackReviewString;
- (NSString*)startScreenMessage;
- (NSString*)openerScreenMessage;
- (NSString*)composerMicErrorScreenMessage;
- (NSString*)openerMicErrorScreenMessage;
- (NSString*)emailMessage;
- (NSString*)smsMessage;
- (NSString *)emailSubject;
- (NSString *)replyMessage;
- (NSString *) feedbackEmailSubject;
- (NSString *) feedbackEmailBody;
- (NSNumber*) showAppFeedbackAfterThisNumberOfResponses;

- (void)refresh;

- (BOOL) shouldShowKillScreen;
- (void) showKillScreen;


@property (strong, readonly) RefreshGroundControlFailureBlock refreshFailureBlock;
@property (strong, readonly) RefreshGroundControlSuccessBlock refreshSuccessBlock;

@end
