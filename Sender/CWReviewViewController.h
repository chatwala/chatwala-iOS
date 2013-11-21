//
//  CWReviewViewController.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWMessageItem;
@interface CWReviewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *recordAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic,assign) NSTimeInterval startRecordingTime;
@property (nonatomic,strong) CWMessageItem * incomingMessageItem;
- (IBAction)onRecordAgain:(id)sender;
- (IBAction)onSend:(id)sender;
- (void)showVideoPreview;
@end
