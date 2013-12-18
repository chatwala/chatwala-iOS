//
//  CWComposerViewController.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWVideoManager.h"
#import "CWMiddleButton.h"
#import "CWViewController.h"
@interface CWComposerViewController : CWViewController <CWVideoRecorderDelegate>
- (void)showReview;
@property (nonatomic, weak) IBOutlet CWMiddleButton * middleButton;
@end
