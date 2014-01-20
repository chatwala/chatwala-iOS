//
//  CWReviewViewController.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWViewController.h"
@class CWMessageItem;
@class CWMiddleButton;
@class User;
@class Message;

@interface CWReviewViewController : CWViewController
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet CWMiddleButton *sendButton;
@property (nonatomic,assign) NSTimeInterval startRecordingTime;
@property (nonatomic) Message * incomingMessage;
- (IBAction)onRecordAgain:(id)sender;
- (IBAction)onSend:(id)sender;
- (void)showVideoPreview;

- (CWMessageItem*)createMessageItemWithSender:(User*) localUser;

@end
