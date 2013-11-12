//
//  CWVideoRecorderTests.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWVideoRecorder.h"
#import "AVCamRecorder.h"
#import <TargetConditionals.h>

@interface CWVideoRecorder ()
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic,strong) AVCamRecorder *recorder;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer * videoPreviewLayer;
@end

@interface CWVideoRecorderTests : XCTestCase
@property (nonatomic,strong) CWVideoRecorder * sut;
@end

@implementation CWVideoRecorderTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWVideoRecorder alloc]init];
}

- (void)tearDown
{
    self.sut = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExists
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testSetupSessionCreatesSession
{
#if (!TARGET_IPHONE_SIMULATOR)
    [self.sut setupSession];
    XCTAssertNotNil(self.sut.session, @"session should not be nil");
#endif
}

- (void)testSetupSessionCreatesVideoInput
{
#if (!TARGET_IPHONE_SIMULATOR)
    [self.sut setupSession];
    XCTAssertNotNil(self.sut.videoInput, @"videoInput should not be nil");
#endif
}

- (void)testSetupSessionCreatesAudioInput
{
#if (!TARGET_IPHONE_SIMULATOR)
    [self.sut setupSession];
    XCTAssertNotNil(self.sut.audioInput, @"audioInput should not be nil");
#endif
}


- (void)testSetupSessionCreatesRecorderView
{
#if (!TARGET_IPHONE_SIMULATOR)
    [self.sut setupSession];
    XCTAssertNotNil(self.sut.recorderView, @"recorderView should not be nil");
#endif
}


- (void)testSetupSessionCreatesVideoPreviewLayer
{
#if (!TARGET_IPHONE_SIMULATOR)
    [self.sut setupSession];
    XCTAssertNotNil(self.sut.videoPreviewLayer, @"videoPreviewLayer should not be nil");
#endif
}


@end
