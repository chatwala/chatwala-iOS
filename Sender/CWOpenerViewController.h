//
//  CWOpenerViewController.h
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWVideoManager.h"
#import "CWMiddleButton.h"
#import "CWViewController.h"
#import "Message.h"

typedef enum {
    CWOpenerPreview,
    CWOpenerReview,
    CWOpenerReact,
    CWOpenerRespond
}CWOpenerState;

//static NSString *const FEEDBACK_RESPONSE_STRING = @"Recording Response 0:%02d";
//static NSString *const FEEDBACK_REACTION_STRING = @"Recording Reaction 0:%02d";
//static NSString *const FEEDBACK_REVIEW_STRING   = @"Recording Reaction in 0:%02d";




@interface CWOpenerViewController : CWViewController <CWVideoPlayerDelegate,CWVideoRecorderDelegate>
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet CWMiddleButton *middleButton;
@property (nonatomic,assign) CWOpenerState openerState;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic, strong) Message * activeMessage;

- (void)setZipURL:(NSURL *) zipURL;
- (void)onMiddleButtonTap;
@end
