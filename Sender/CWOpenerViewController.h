//
//  CWOpenerViewController.h
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

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

@interface CWOpenerViewController : CWViewController <CWVideoPlayerDelegate,CWVideoRecorderDelegate>
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet CWMiddleButton *middleButton;
@property (nonatomic,assign) CWOpenerState openerState;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic, strong) Message * activeMessage;
@property (nonatomic,assign) BOOL shouldPromptBeforeSending;

- (void)setZipURL:(NSURL *) zipURL;
- (void)onMiddleButtonTap;
@end
