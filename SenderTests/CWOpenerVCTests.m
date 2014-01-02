//
//  CWOpenerVCTests.m
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWSSOpenerViewController.h"
#import "CWFeedbackViewController.h"
#import "CWVideoManager.h"
#import "CWMessageItem.h"
#import "CWGroundControlManager.h"

@interface CWOpenerViewController () <AVAudioPlayerDelegate,CWVideoPlayerDelegate,CWVideoRecorderDelegate>
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) NSTimer * reviewCountdownTimer;
@property (nonatomic,strong) NSTimer * reactionCountdownTimer;
@property (nonatomic,strong) NSTimer * responseCountdownTimer;
- (void)onResponseCountdownTick:(NSTimer*)timer;
- (void)onReactionCountdownTick:(NSTimer*)timer;
- (void)onReviewCountdownTick:(NSTimer*)timer;
- (void)startResponseCountDown;
- (void)startReviewCountDown;
- (void)startReactionCountDown;
- (void)setupCameraView;
@property (nonatomic, strong) NSDate * startTime;
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
    self.sut = [[CWSSOpenerViewController alloc]init];
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
    [self.sut viewWillAppear:YES];
    [self.mockSUT verify];
}

- (void)testShouldSetRecorderDelegateWhenViewWillAppear
{
    [self prepMessageItem];
    [[self.mockRecorder expect]setDelegate:self.sut];
    [self.sut viewWillAppear:NO];
    [self.mockRecorder verify];
}

- (void)testShouldSetVideoUrlOnPlayerWhenViewWillAppear
{
    [self prepMessageItem];
    [self.sut viewWillAppear:YES];
    [self.mockPlayer verify];
}

- (void) testShouldAddVideoPlayerViewWhenVideoIsReady {
    //given
    [self prepMessageItem];
    [self.sut viewWillAppear:NO];
    UIView * dummyView = [[UIView alloc]init];
    id mockPlaybackView = [OCMockObject partialMockForObject:dummyView];
    [[[self.mockSUT stub]andReturn:mockPlaybackView]playbackView];
    [[mockPlaybackView expect]addSubview:OCMOCK_ANY];
    
    //when
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
    
    //should
    [mockPlaybackView verify];
    [self.mockRecorder verify];

    //cleanup
    [mockPlaybackView stopMocking];

}

- (void)testShouldCreateMessageItemWhenZipUrlIsSet
{
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockSUT expect]setMessageItem:OCMOCK_ANY];
    [self.sut setZipURL:mockUrl];
    [self.mockSUT verify];
}


- (void) testShouldPushToReviewVCWhenRecordingFinishes {
    
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]pushViewController:OCMOCK_ANY animated:NO];
    
    [[[self.mockSUT stub] andReturnValue:@(CWOpenerRespond)] openerState];
    
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

    [self.sut startReactionCountDown];
    XCTAssertNotNil(self.sut.reactionCountdownTimer, @"should NOT be nil");
}

- (void)testShouldCreateResponseTimerWhenStartResponseCountdownInvoked
{
    XCTAssertNil(self.sut.responseCountdownTimer, @"should be nil");
    [self.sut startResponseCountDown];
    XCTAssertNotNil(self.sut.responseCountdownTimer, @"should NOT be nil");
}

- (void)testShouldInvokeStartResponseTimerWhenVideoPlaybackFinishes
{
    [[self.mockSUT expect]startResponseCountDown];
    [self.sut videoPlayerPlayToEnd:self.sut.player];
    [self.mockSUT verify];
}

- (void)testShouldSetOpenerStateToRespondWhenVideoPlaybackFinishes
{
    [[self.mockSUT expect] setOpenerState:CWOpenerRespond];
    [self.sut videoPlayerPlayToEnd:nil];
    [self.mockSUT verify];
}

- (void)testShouldStartRecordingWhenStartReactionCountdownInvoked
{
    [[self.mockRecorder expect]startVideoRecording];
    [[[self.mockSUT stub]andReturn:self.mockRecorder]recorder];


    [self.sut startReactionCountDown];
    [self.mockRecorder verify];
}



- (void)testShouldStopRecordingOnTouchsEnded
{
    //given
    [self prepMessageItem];
    self.sut.openerState = CWOpenerRespond;
    [self.sut viewWillAppear:NO];
    [[self.mockRecorder expect]stopVideoRecording];
    
    //when
    [self.sut onMiddleButtonTap];
    
    //should
    [self.mockRecorder verify];
    
}

#pragma mark setOpenerState

- (void)testShouldStartResponseCountDownWhenOpenerStateIsSetToReview
{
    [self prepMessageItem];
    self.sut.messageItem.metadata.startRecording = 2;
    [[self.mockSUT expect] startReviewCountDown];
    [self.sut setOpenerState:CWOpenerReview];
    [self.mockSUT verify];
}

- (void)testShouldSetStateToReviewWhenOpenerStateIsSetToReview
{
    [self prepMessageItem];
    self.sut.messageItem.metadata.startRecording = 0;
    [[self.mockSUT expect] setOpenerState:CWOpenerReview];
    [self.sut setOpenerState:CWOpenerReview];
    [self.mockSUT verify];
}

- (void)testShouldStartResponseCountDownWhenOpenerStateIsSetToReact
{
    [[self.mockSUT expect] startReactionCountDown];
    [self.sut setOpenerState:CWOpenerReact];
    [self.mockSUT verify];
}
- (void)testShouldStartResponseCountDownWhenOpenerStateIsSetToResponse
{
    [[self.mockSUT expect] startReactionCountDown];
    [self.sut setOpenerState:CWOpenerReact];
    [self.mockSUT verify];
}


@end
