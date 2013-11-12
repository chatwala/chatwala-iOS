//
//  CWVideoRecorder.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CWVideoRecorder;

@interface CWVideoRecorder : NSObject
@property (nonatomic,weak) id<CWVideoRecorder> delegate;
- (void) setupSession;
- (void) startRecording;
- (void) stopRecording;
@end



@protocol CWVideoRecorder <NSObject>

- (void)recorder:(CWVideoRecorder*)recorder didFailWithError:(NSError *)error;
- (void)recorderRecordingBegan:(CWVideoRecorder *)recorder;
- (void)recorderRecordingFinished:(CWVideoRecorder *)recorder;

@end