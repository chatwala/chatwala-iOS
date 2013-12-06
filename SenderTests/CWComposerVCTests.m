//
//  CWComposerVCTests.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWSSComposerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWReviewViewController.h"
#import "CWVideoManager.h"

@interface CWComposerViewController (tests) <AVAudioPlayerDelegate>
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWReviewViewController * reviewVC;
@property (nonatomic, strong) NSDate * startTime;

@property (nonatomic,strong) NSTimer * recordTimer;
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
    self.sut = [[CWSSComposerViewController alloc]init];
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

- (void) testShouldChangeButtonStateWhenStartReconding
{
    [self.sut view];
    OCMockObject * middleButtonMock = [OCMockObject partialMockForObject:self.sut.middleButton];
    [[middleButtonMock expect] setButtonState:eButtonStateStop];

    [[self.mockRecorder expect]startVideoRecording];
    
    
    [self.sut startRecording];
    
    [self.mockRecorder verify];
    [middleButtonMock verify];
    [middleButtonMock stopMocking];
}

- (void)testShouldStopRecordingWhenTimerReachesZero
{
    [[self.mockRecorder expect]stopVideoRecording];
    self.sut.startTime = [NSDate dateWithTimeIntervalSinceNow:-MAX_RECORD_TIME];
    [self.sut onTick:self.sut.recordTimer];
    [self.mockRecorder verify];
}

- (void)testShouldStopRecordingOnTouchsEnded
{
    [[self.mockRecorder expect]stopVideoRecording];
    [self.sut touchesEnded:nil withEvent:nil];
    [self.mockRecorder verify];
    
}

- (void)testShouldPushReviewViewControllerWhenRecordingFinishedAndTickCountIsZero
{
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    
    CWVideoRecorder * recorder = [[CWVideoManager sharedManager]recorder];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]pushViewController:OCMOCK_ANY animated:NO];
    
    self.sut.startTime = [NSDate dateWithTimeIntervalSinceNow:-MAX_RECORD_TIME];

    [[recorder delegate]recorderRecordingFinished:recorder];
    
}

@end
