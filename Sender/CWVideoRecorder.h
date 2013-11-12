//
//  CWVideoRecorder.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWVideoRecorder : NSObject
- (void) setupSession;
- (void) startRecording;
- (void) stopRecording;
@end
