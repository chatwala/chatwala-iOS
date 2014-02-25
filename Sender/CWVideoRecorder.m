//
//  CWVideoRecorder.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoRecorder.h"
#import "AVCamRecorder.h"
#import "AppDelegate.h"
#import "CWErrorViewController.h"
#import "CWUtility.h"


@interface CWVideoRecorder () <AVCamRecorderDelegate>
{
    NSDate * recordingStartTime;
}
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
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
        [self.recorderView setAlpha:0.0];
        
        [self checkForMicAccess];
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



- (void)checkForMicAccess
{
    
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
           if (granted) {
                
            }else{
                [self presentErrorScreen];
            }
        }];
    }
}

- (void)presentErrorScreen
{
    AppDelegate * appdel = [[UIApplication sharedApplication] delegate];
    CWErrorViewController * errScreen = [[CWErrorViewController alloc]init];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![appdel.navController.visibleViewController isKindOfClass:[CWErrorViewController class]]) {
            [appdel.navController pushViewController:errScreen animated:NO];
        }
    });
}

- (NSTimeInterval) videoLength
{
    return [[NSDate date] timeIntervalSinceDate:recordingStartTime];
}


- (void) stopSession
{
    [self.session stopRunning];
}

- (void) resumeSession
{
    if (self.session) {
        //
        [self.session startRunning];
        
    }else{
        [self setupSession];
    }
}


- (NSError*) setupSession
{
    
    NSError * err = nil;
    
    if (self.session) {
        return err;
    }
    
    // setup device inputs
    AVCaptureDeviceInput * videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self frontFacingCamera] error:&err];
    if (err) {
        NSLog(@"failed to setup video input: %@",err.debugDescription);
        [self presentErrorScreen];
//        return err;
    }
    
    AVCaptureDeviceInput * audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self audioDevice] error:&err];
    if (err) {
        NSLog(@"failed to setup audio input: %@",err.debugDescription);
//        return err;
        [self presentErrorScreen];
    }
    
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    outputSettings = nil;
    
    AVCaptureSession * session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetMedium];

    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    
    if ([session canAddInput:audioInput]) {
        [session addInput:audioInput];
    }
    
    if([session canAddOutput:newStillImageOutput])
    {
        [session addOutput:newStillImageOutput];
    }
    
    [self setStillImageOutput:newStillImageOutput];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.0 animations:^{
                [self.recorderView setAlpha:1.0];
            }];
        });
        
    });
    
    return err;

}

- (NSURL *) tempFileURL
{
    return [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"output.mp4"];
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

- (void) startVideoRecording
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
    recordingStartTime = [NSDate date];
}

- (void) stopVideoRecording
{
    [[self recorder] stopRecording];
}

- (void) captureStillImageWithCallback:(void (^)(UIImage * image, NSError * error))completionBlock
{
    AVCaptureConnection *stillImageConnection = [[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo];
    if ([stillImageConnection isVideoOrientationSupported])
    {
        [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
															 
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             
                                                             completionBlock(image, error);
                                                             
                                                         }];

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

- (AVAssetExportSession*)createVideExporterWithSourceVideoURL:(NSURL*)videoURL_in andOutPutURL:(NSURL*)videoURL_out
{
    AVAsset * videoAsset = [AVAsset assetWithURL:videoURL_in];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetMediumQuality];
    [exporter setOutputFileType:AVFileTypeMPEG4];
    [exporter setOutputURL:videoURL_out];
    
    return exporter;

}


- (void)converVideoWithURL:(NSURL*)videoURL
{
    self.outputFileURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[[NSUUID UUID] UUIDString],@".mp4"]];
    
    // setup exporter
    AVAssetExportSession *exporter = [self createVideExporterWithSourceVideoURL:videoURL andOutPutURL:self.outputFileURL];
    
    __block CWVideoRecorder* blockSelf = self;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        // video completed export
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.delegate recorderRecordingFinished:blockSelf];
        });
    }];
}


#pragma mark AVCamRecorderDelegate

- (void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
    [self converVideoWithURL:outputFileURL];
    
    if (self.backgroundRecordingID != 0) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundRecordingID];
        self.backgroundRecordingID = 0;
    }
}

- (void)recorderRecordingDidBegin:(AVCamRecorder *)recorder
{
    if ([self.delegate respondsToSelector:@selector(recorderRecordingBegan:)]) {
        [self.delegate recorderRecordingBegan:self];
    }
}

@end