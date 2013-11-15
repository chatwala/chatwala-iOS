//
//  CWComposerVCTests.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWComposerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWReviewViewController.h"
#import "CWVideoManager.h"

@interface CWComposerViewController () <AVAudioPlayerDelegate>
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWReviewViewController * reviewVC;
@property (nonatomic,strong) NSTimer * recordTimer;
@property (nonatomic,assign) NSInteger tickCount;
- (void)startRecording;
- (void)stopRecording;
- (void)onTick:(NSTimer*)timer;
@end

@interface CWComposerVCTests : XCTestCase
@property (nonatomic,strong) CWComposerViewController * sut;
@property (nonatomic,strong) id mockRecorder;
@end

@implementation CWComposerVCTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWComposerViewController alloc]init];
    self.mockRecorder = [OCMockObject partialMockForObject:[[CWVideoManager sharedManager] recorder]];
}

- (void)tearDown
{
    
    self.sut = nil;
    [self.mockRecorder stopMocking];
    self.mockRecorder = nil;
    
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExist
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testShouldConformToCWVideoRecorderDelegate
{
    XCTAssertTrue([self.sut conformsToProtocol:@protocol(CWVideoRecorderDelegate)], @"should conform to CWVideoRecorderDelegate protocol");
}

- (void)testShouldSetVideoMangerDelegateToSelfOnViewDidLoad
{
    [[self.mockRecorder expect]setDelegate:self.sut];
    [self.sut view];
}

- (void)testShouldCreateFeedbackVConViewDidLoad
{
    XCTAssertNil(self.sut.feedbackVC, @"should be nil");
    [self.sut view];
    XCTAssertNotNil(self.sut.feedbackVC, @"should not be nil");
}

- (void)testShouldStartRecordingWhenViewDidAppear
{
    [[self.mockRecorder expect]startVideoRecording];
    [self.sut viewDidAppear:NO];
}

- (void)testShouldSetTickCountToMaxWhenRecordingStarts
{
    id mockSUT = [OCMockObject partialMockForObject:self.sut];
    [[mockSUT expect]setTickCount:MAX_RECORD_TIME];
    [self.sut startRecording];
    [mockSUT stopMocking];
}

- (void)testShouldStopRecordingWhenTimerReachesZero
{
    [[self.mockRecorder expect]stopVideoRecording];
    [self.sut setTickCount:1];
    [self.sut onTick:self.sut.recordTimer];
}

- (void)testShouldStopRecordingOnTouchsEnded
{
    [[self.mockRecorder expect]stopVideoRecording];
    [self.sut touchesEnded:nil withEvent:nil];
    
}

- (void)testShouldPushReviewViewControllerWhenRecordingFinishedAndTickCountIsZero
{
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    
    CWVideoRecorder * recorder = [[CWVideoManager sharedManager]recorder];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]pushViewController:self.sut.reviewVC animated:NO];
    
    [self.sut setTickCount:0];
    [[recorder delegate]recorderRecordingFinished:recorder];
    
}

- (void)testShouldRestartTimerWhenRecordingBegins
{
    id mockTimer = [OCMockObject mockForClass:[NSTimer class]];
    id mockSUT = [OCMockObject partialMockForObject:self.sut];
    [[mockSUT stub]andReturn:mockTimer];
    [[mockTimer expect]invalidate];
    [[mockSUT expect]setRecordTimer:OCMOCK_ANY];
    [self.sut recorderRecordingFinished:self.mockRecorder];
    [mockSUT stopMocking];
}

- (void)testShouldUpdateFeedbackWhenOnTickEnvoked
{
    [self.sut view];
    id mockFeedbackLabel = [OCMockObject partialMockForObject:self.sut.feedbackVC.feedbackLabel];
    [self.sut setTickCount:7];
    [[mockFeedbackLabel expect]setText:[NSString stringWithFormat:@"Recording 0:%02d",7]];
    [self.sut onTick:nil];
}

@end
