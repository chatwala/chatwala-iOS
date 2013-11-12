//
//  CWReviewViewController.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWReviewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *recordAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)onRecordAgain:(id)sender;
- (IBAction)onSend:(id)sender;
@end
