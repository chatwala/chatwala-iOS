//
//  CWOpenerVCTests.m
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWOpenerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWVideoManager.h"
#import "CWMessageItem.h"

@interface CWOpenerViewController () <AVAudioPlayerDelegate,CWVideoPlayerDelegate,CWVideoRecorderDelegate>
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) NSTimer * reviewCountdownTimer;
@property (nonatomic,strong) NSTimer * reactionCountdownTimer;
@property (nonatomic,strong) NSTimer * responseCountdownTimer;
@property (nonatomic,assign) NSInteger reviewCountdownTickCount;
@property (nonatomic,assign) NSInteger reactionCountdownTickCount;
@property (nonatomic,assign) NSInteger responseCountdownTickCount;
- (void)onResponseCountdownTick:(NSTimer*)timer;
- (void)onReactionCountdownTick:(NSTimer*)timer;
- (void)onReviewCountdownTick:(NSTimer*)timer;
- (void)startResponseCountDown;
- (void)startReviewCountDown;
- (void)startReactionCountDown;
- (void)setupCameraView;
@end

@interface CWOpenerVCTests : XCTestCase
@property (nonatomic,strong) CWOpenerViewController * sut;
@property (nonatomic,strong) id mockSUT;
@property (nonatomic,strong) id mockPlayer;
@property (nonatomic,strong) id mockRecorder;
@property (nonatomic,strong) id mockReviewTimer;
@property (nonatomic,strong) id mockReactionTimer;
@property (nonatomic,strong) id mockResponseTimer;

@end

@implementation CWOpenerVCTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWOpenerViewController alloc]init];
    [self.sut view];
    self.mockSUT = [OCMockObject partialMockForObject:self.sut];
    self.mockPlayer = [OCMockObject partialMockForObject:[[CWVideoManager sharedManager] player]];
    self.mockRecorder = [OCMockObject partialMockForObject:[[CWVideoManager sharedManager] recorder]];
    
    self.mockReactionTimer = [OCMockObject mockForClass:[NSTimer class]];
    self.mockResponseTimer = [OCMockObject mockForClass:[NSTimer class]];
    self.mockReviewTimer = [OCMockObject mockForClass:[NSTimer class]];
    
    
}

- (void)tearDown
{
    [self.mockSUT stopMocking];
    [self.mockRecorder stopMocking];
    [self.mockPlayer stopMocking];
    [self.mockReactionTimer stopMocking];
    [self.mockResponseTimer stopMocking];
    [self.mockReviewTimer stopMocking];
    
    self.mockSUT = nil;
    self.mockPlayer = nil;
    self.mockRecorder = nil;
    self.mockReactionTimer = nil;
    self.mockResponseTimer = nil;
    self.mockReviewTimer = nil;
    
    
    self.sut = nil;
    
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExists
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testShouldConformToCWVideoPlayerDelegateProtocol
{
    XCTAssertTrue([self.sut conformsToProtocol:@protocol(CWVideoPlayerDelegate)], @"should conform to CWVideoPlayerDelegate protocol");
}

- (void)testShouldConformToCWVideoRecorderDelegateProtocol
{
    XCTAssertTrue([self.sut conformsToProtocol:@protocol(CWVideoRecorderDelegate)], @"should conform to CWVideoRecorderDelegate protocol");
}

// prepare message item
// • use when invoking viewWill/Did* methods to prevent issues with SUT attempting to load video file

- (void)prepMessageItem
{
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockPlayer stub]setVideoURL:mockUrl];
    
    [self.sut setMessageItem:[[CWMessageItem alloc] init]];
    [self.sut.messageItem setVideoURL:mockUrl];
}


- (void)testShouldSetPlayerDelegateWhenViewWillAppear
{
    [self prepMessageItem];
    [[self.mockPlayer expect]setDelegate:self.sut];
    [[self.mockSUT stub] setOpenerState:CWOpenerReview];
    [self.sut viewWillAppear:NO];
    [self.mockPlayer verify];
}

/*
 should be in the pip tests
- (void) testCameraViewShouldBeHiddenWhenViewWillAppear {
    [self prepMessageItem];
    [self.sut viewWillAppear:NO];
    XCTAssertTrue(self.sut.cameraView.hidden, @"should be hidden");
}

- (void) testCameraViewShouldNotBeHiddenWhenReactionTimerStarts {
    [self.sut startReactionCountDown];
    XCTAssertFalse(self.sut.cameraView.hidden, @"should NOT be hidden");
}
- (void) testShouldResizeCameraViewWhenVideoPlaybackFinishes {
    
    id mockCameraView = [OCMockObject partialMockForObject:self.sut.cameraView];
    [[mockCameraView expect]setFrame:self.sut.view.bounds];
    [[[self.mockSUT stub]andReturn:mockCameraView]cameraView];
    
    [self.sut videoPlayerPlayToEnd:self.sut.player];

    [mockCameraView verify];
    [mockCameraView stopMocking];
}

*/
- (void) testshouldInvokeSetupCameraWhenViewLoads {
    [self prepMessageItem];
    [[self.mockSUT expect]setupCameraView];
    [[self.mockSUT stub] setOpenerState:CWOpenerReview];
    [self.sut viewWillAppear:YES];
    [self.mockSUT verify];
}

- (void)testShouldSetRecorderDelegateWhenViewWillAppear
{
    [self prepMessageItem];
    [[self.mockRecorder expect]setDelegate:self.sut];
    [[self.mockSUT stub] setOpenerState:CWOpenerReview];
    [self.sut viewWillAppear:NO];
    [self.mockRecorder verify];
}

- (void)testShouldSetVideoUrlOnPlayerWhenViewWillAppear
{
    [self prepMessageItem];
    [[self.mockSUT stub] setOpenerState:CWOpenerReview];
    [self.sut viewWillAppear:YES];
    [self.mockPlayer verify];
}

- (void) testShouldAddVideoPlayerViewWhenVideoIsReady {
    
    id mockPlaybackView = [OCMockObject partialMockForObject:self.sut.playbackView];
    [[mockPlaybackView expect]addSubview:self.sut.player.playbackView];
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
    [mockPlaybackView verify];
    [mockPlaybackView stopMocking];
    
}

- (void)testShouldCreateMessageItemWhenZipUrlIsSet
{
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockSUT expect]setMessageItem:OCMOCK_ANY];
    [self.sut setZipURL:mockUrl];
    [self.mockSUT verify];
}


- (void)testShouldCreateFeedbackVC
{
    XCTAssertNotNil(self.sut.feedbackVC, @"feedback should be created");
}


- (void)testShouldStartTheResponseCountDown
{
    [self.sut videoPlayerPlayToEnd:self.sut.player];
    
    XCTAssertEqual(self.sut.responseCountdownTickCount, MAX_RECORD_TIME, @"expecting the coutn down to be started at MAX_RECORD_TIME");
    XCTAssertNotNil(self.sut.responseCountdownTimer, @"expecting the response timer to exist");
    NSString * actual = self.sut.feedbackVC.feedbackLabel.text;
    NSString * expected = [NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,MAX_RECORD_TIME];
    XCTAssertTrue([expected isEqualToString:actual], @"expecting feedback label should match");
    
}

- (void) testShouldUpdateFeedbackLabelWhenResponseTimerTicks{
    
    [self.sut setResponseCountdownTickCount:21];
    [self.sut onResponseCountdownTick:nil];
    NSString * actual = self.sut.feedbackVC.feedbackLabel.text;
    NSString * expected = [NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,20];
    XCTAssertTrue([expected isEqualToString:actual], @"expecting feedback label should match");
}


- (void) testShouldInvalidateResponseTimerWhenItReachesZero {

    [self.sut setResponseCountdownTickCount:1];
    [self.sut onResponseCountdownTick:nil];
    
    XCTAssertNil(self.sut.responseCountdownTimer, @"response timer should be nil");
}

- (void) testShouldPushToReviewVCWhenRecordingFinishes {
    
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]pushViewController:OCMOCK_ANY animated:NO];
    
    [self.sut recorderRecordingFinished:self.sut.recorder];
    
    [mockNavController verify];
    [mockNavController stopMocking];
    
}

- (void)testShouldStartPlaybackWhenVideoLoads
{
    [[self.mockPlayer expect]playVideo];
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
}

- (void)testShouldStartReviewTimerWhenVideoLoads {
    [[self.mockSUT expect]startReviewCountDown];
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
}

- (void)testShouldCreateReviewTimerWhenStartReviewCountdownInvoked
{
    XCTAssertNil(self.sut.reviewCountdownTimer, @"should be nil");
    [self.sut startReviewCountDown];
    XCTAssertNotNil(self.sut.reviewCountdownTimer, @"should NOT be nil");
}


- (void)testShouldCreateReactionTimerWhenStartReactionCountdownInvoked
{
    XCTAssertNil(self.sut.reactionCountdownTimer, @"should be nil");
    [[self.mockSUT stub] setOpenerState:CWOpenerReact];
    [self.sut startReactionCountDown];
    XCTAssertNotNil(self.sut.reactionCountdownTimer, @"should NOT be nil");
}

- (void)testShouldCreateResponseTimerWhenStartResponseCountdownInvoked
{
    XCTAssertNil(self.sut.responseCountdownTimer, @"should be nil");
    [[self.mockSUT stub] setOpenerState:CWOpenerRespond];
    [self.sut startResponseCountDown];
    XCTAssertNotNil(self.sut.responseCountdownTimer, @"should NOT be nil");
}

- (void)testShouldInvokeStartResponseTimerWhenVideoPlaybackFinishes
{
    [[self.mockSUT expect]startResponseCountDown];
    [self.sut videoPlayerPlayToEnd:self.sut.player];
    [self.mockSUT verify];
}


- (void)testShouldInvalidateReactionTimerWhenVideoPlaybackFinishes
{
    [[self.mockReactionTimer expect]invalidate];
    [[[self.mockSUT stub]andReturn:self.mockReactionTimer]reactionCountdownTimer];
    [[self.mockSUT stub] setOpenerState:CWOpenerRespond];
    [self.sut videoPlayerPlayToEnd:self.sut.player];
    [self.mockReactionTimer verify];
}

- (void)testShouldSetReactionTimerToNilWhenVideoPlaybackFinishes
{
    [[self.mockReactionTimer expect]invalidate];
    [[self.mockSUT expect]setReactionCountdownTimer:nil];
    [[[self.mockSUT stub]andReturn:self.mockReactionTimer]reactionCountdownTimer];
    [[self.mockSUT stub] setOpenerState:CWOpenerRespond];

    [self.sut videoPlayerPlayToEnd:self.sut.player];
    [self.mockSUT verify];
}

- (void)testShouldStartRecordingWhenStartReactionCountdownInvoked
{
    [[self.mockRecorder expect]startVideoRecording];
    [[[self.mockSUT stub]andReturn:self.mockRecorder]recorder];
    [[self.mockSUT stub] setOpenerState:CWOpenerReact];

    [self.sut startReactionCountDown];
    [self.mockRecorder verify];
}

- (void)testShouldSetReactionTickCountToZeroWhenStartReactionCountdownInvoked
{
    [[self.mockSUT stub] setOpenerState:CWOpenerReact];

    [self.sut startReactionCountDown];
    XCTAssert(self.sut.reactionCountdownTickCount == 0, @"should be zero");
}


- (void) testShouldUpdateFeedbackLabelWhenReactionTimerTicks{
    
    [self.sut setReactionCountdownTickCount:20];
    [self.sut onReactionCountdownTick:nil];
    NSString * actual = self.sut.feedbackVC.feedbackLabel.text;
    NSString * expected = [NSString stringWithFormat:FEEDBACK_REACTION_STRING,21];
    XCTAssertTrue([expected isEqualToString:actual], @"expecting feedback label should match");
}

- (void) testShouldUpdateFeedbackLabelWhenReviewTimerTicks{
    
    [self.sut setResponseCountdownTickCount:21];
    [self.sut onResponseCountdownTick:nil];
    NSString * actual = self.sut.feedbackVC.feedbackLabel.text;
    NSString * expected = [NSString stringWithFormat:FEEDBACK_RESPONSE_STRING,20];
    XCTAssertTrue([expected isEqualToString:actual], @"expecting feedback label should match");
}


- (void)testShouldStopRecordingOnTouchsEnded
{
    [self prepMessageItem];
    self.sut.openerState = CWOpenerRespond;
    [self.sut viewWillAppear:NO];
    [[self.mockRecorder expect]stopVideoRecording];
    [self.sut touchesEnded:nil withEvent:nil];
    [self.mockRecorder verify];
    
}

@end
