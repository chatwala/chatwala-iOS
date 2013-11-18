//
//  CWOpenerViewController.h
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CWOpenerReview,
    CWOpenerReact,
    CWOpenerRespond
}CWOpenerState;

static NSString *const FEEDBACK_RESPONSE_STRING = @"Recording Response 0:%02d";
static NSString *const FEEDBACK_REACTION_STRING = @"Recording Reaction 0:%02d";
static NSString *const FEEDBACK_REVIEW_STRING   = @"Recording Reaction in 0:%02d";




@interface CWOpenerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,strong) NSURL * zipURL;

- (void)enteringCameraState:(CWOpenerState)state;

@end
