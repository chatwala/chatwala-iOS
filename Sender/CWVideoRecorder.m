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
@property (nonatomic,strong) AVCaptureVideoPreviewLayer * videoPreviewLayer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) audioDevice;
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position;
- (void) removeFile:(NSURL *)fileURL;
@end


@implementation CWVideoRecorder


- (id)init
{
    self = [super init];
    if (self) {
        self.recorderView = [[UIView alloc]init];
        [self.recorderView addObserver:self forKeyPath:@"frame" options:kNilOptions context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.session stopRunning];
    
    [self.recorderView removeObserver:self forKeyPath:@"frame"];
    self.recorderView = nil;
    self.videoPreviewLayer = nil;
    self.videoInput = nil;
    self.audioInput = nil;
    self.session = nil;
}


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
    
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.recorderView.layer addSublayer:self.videoPreviewLayer];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
 
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });

}

- (NSURL*)cacheDirectoryURL
{
    return [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
}
- (NSURL *) tempFileURL
{
    return [[self cacheDirectoryURL] URLByAppendingPathComponent:@"output.mp4"];
}
- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            if ([[self delegate] respondsToSelector:@selector(recorder:didFailWithError:)]) {
                [[self delegate] recorder:self didFailWithError:error];
            }
        }
    }
}

- (void) startRecording
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns
		// to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library
		// when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error:
		// after the recorded file has been saved.
        [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}]];
    }
    
    [self removeFile:[[self recorder] outputFileURL]];
    [[self recorder] startRecordingWithOrientation:AVCaptureVideoOrientationPortrait];
}

- (void) stopRecording
{
    [[self recorder] stopRecording];
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


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        
        [self.videoPreviewLayer setFrame:self.recorderView.bounds];
    }
}


#pragma mark AVCamRecorderDelegate

- (void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    
    // setup export
    AVAsset * videoAsset = [AVAsset assetWithURL:outputFileURL];
    AVAssetExportSession *sessionExporter = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetMediumQuality];
    [sessionExporter setOutputFileType:AVFileTypeMPEG4];
    
    NSURL * convertedFileOutputURL = [[self cacheDirectoryURL] URLByAppendingPathComponent:OUTPUT_VIDEO_FILE_NAME];
    [sessionExporter setOutputURL:convertedFileOutputURL];
    
    __block CWVideoRecorder* blockSelf = self;
    
    [sessionExporter exportAsynchronouslyWithCompletionHandler:^{
        // video completed export
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.delegate recorderRecordingFinished:blockSelf];
        });
    }];
    

}

- (void)recorderRecordingDidBegin:(AVCamRecorder *)recorder
{
    if ([self.delegate respondsToSelector:@selector(recorderRecordingBegan:)]) {
        [self.delegate recorderRecordingBegan:self];
    }
}

@end
