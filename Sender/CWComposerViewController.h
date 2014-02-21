//
//  CWComposerViewController.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


#import "CWVideoManager.h"
#import "CWMiddleButton.h"
#import "CWViewController.h"

@interface CWComposerViewController : CWViewController <CWVideoRecorderDelegate>
@property (nonatomic, weak) IBOutlet CWMiddleButton * middleButton;

- (void)showReview;
- (void)onMiddleButtonTap;
@end
