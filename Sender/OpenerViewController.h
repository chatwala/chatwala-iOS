//
//  OpenerViewController.h
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVCamCaptureManager;
@interface OpenerViewController : UIViewController
@property (nonatomic,strong) NSURL * videoURL;
@property (nonatomic,strong) NSURL * zipURL;

@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
- (void)interruptRecording;
- (void)resumeRecording;
@end
