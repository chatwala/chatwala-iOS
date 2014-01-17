//
//  CWStartScreenViewController.h
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWMiddleButton;

@interface CWStartScreenViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet CWMiddleButton *middleButton;
@property (weak, nonatomic) IBOutlet UILabel *startScreenMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sentMessageView;
@property (nonatomic,assign) BOOL showSentMessage;
- (IBAction)onStart:(id)sender;

- (void)onMiddleButtonTap;
@end

