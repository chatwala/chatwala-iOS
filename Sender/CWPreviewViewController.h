//
//  CWReviewViewController.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


#import "CWViewController.h"

@class CWMiddleButton;
@class User;
@class Message;

@interface CWPreviewViewController : CWViewController
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet CWMiddleButton *sendButton;
@property (nonatomic,assign) NSTimeInterval startRecordingTime;
@property (nonatomic,assign) NSString *messageRecipientID;
@property (nonatomic) Message * incomingMessage;
@property (weak, nonatomic) IBOutlet UIImageView *incomingMessageStillImageView;
- (IBAction)onRecordAgain:(id)sender;
- (IBAction)onSend:(id)sender;
- (void)showVideoPreview;


@end
