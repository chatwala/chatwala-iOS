//
//  CWGroundControlManager.h
//  Sender
//
//  Created by Khalid on 11/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (NSString *)emailSubject;
- (void)refresh;

@end
