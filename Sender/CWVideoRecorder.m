//
//  CWVideoRecorder.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoRecorder.h"
#import "AVCamRecorder.h"

@interface CWVideoRecorder () <AVCamRecorderDelegate>
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic,strong) AVCamRecorder *recorder;
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
    
    NSURL *outputFileURL = [self tempFileURL];
    AVCamRecorder * recorder = [[AVCamRecorder alloc]initWithSession:self.session outputFileURL:outputFileURL];
    [recorder setDelegate:self];
    
    // check if recorder can record
    
    if (![recorder recordsVideo] && [recorder recordsAudio]) {
        NSString *localizedDescription = NSLocalizedString(@"Video recording unavailable", @"Video recording unavailable description");
		NSString *localizedFailureReason = NSLocalizedString(@"Movies recorded on this device will only contain audio. They will be accessible through iTunes file sharing.", @"Video recording unavailable failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *noVideoError = [NSError errorWithDomain:@"CWVideoRecorder" code:0 userInfo:errorDict];
		if ([[self delegate] respondsToSelector:@selector(recorder:didFailWithError:)]) {
			[[self delegate] recorder:self didFailWithError:noVideoError];
		}
    }
    
    [self setRecorder:recorder];
    recorder = nil;
    
    
    
}

- (NSURL*)cacheDirectoryURL
{
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}
- (NSURL *) tempFileURL
{
    return [[self cacheDirectoryURL] URLByAppendingPathComponent:@"output.mp4"];
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


#pragma mark AVCamRecorderDelegate

- (void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    
}

- (void)recorderRecordingDidBegin:(AVCamRecorder *)recorder
{
    
}

@end
