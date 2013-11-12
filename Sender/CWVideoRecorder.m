//
//  CWVideoRecorder.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoRecorder.h"

@interface CWVideoRecorder ()
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureDeviceInput *audioInput;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) audioDevice;
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position;
@end


@implementation CWVideoRecorder


- (void) setupSession
{
    
    NSError * err = nil;
    
    // setup device inputs
    AVCaptureDeviceInput * videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self frontFacingCamera] error:&err];
    if (err) {
        NSLog(@"failed to setup video input: %@",err.debugDescription);
        return;
    }
    
    AVCaptureDeviceInput * audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self audioDevice] error:&err];
    if (err) {
        NSLog(@"failed to setup audio input: %@",err.debugDescription);
        return;
    }
    
    AVCaptureSession * session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetMedium];
    
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    
    if ([session canAddInput:audioInput]) {
        [session addInput:audioInput];
    }
    
    [self setAudioInput:audioInput];
    [self setVideoInput:videoInput];
    [self setSession:session];
    
    
    
    
    
}

- (void) startRecording
{
    
}

- (void) stopRecording
{
    
}



- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}


- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
@end
