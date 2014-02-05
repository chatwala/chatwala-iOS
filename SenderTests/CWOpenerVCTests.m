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
#import "CWVideoManager.h"
#import "CWGroundControlManager.h"
#import "CWDataManager.h"
#import "Message.h"
#import "MocForTests.h"

@interface CWOpenerViewController () <AVAudioPlayerDelegate,CWVideoPlayerDelegate,CWVideoRecorderDelegate>
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
@property (nonatomic) NSManagedObjectContext * moc;

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
    
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.moc = mocFactory.moc;
    
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
    Message * message = [Message insertInManagedObjectContext:self.moc];
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockPlayer stub]setVideoURL:mockUrl];
    
    [self.sut setActiveMessage:message];
    message.videoURL = mockUrl;
}


- (void)testShouldSetPlayerDelegateWhenViewWillAppear
{
    //given
    [self prepMessageItem];
    [[self.mockPlayer expect]setDelegate:self.sut];

    //when
    [self.sut viewWillAppear:NO];
    
    //should
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
    [[self.mockPlayer expect] createStillForLastFrameWithCompletionHandler:OCMOCK_ANY];
    
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
    //given
    id mockMessage = [OCMockObject niceMockForClass:[Message class]];
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    id mockDataManager = [OCMockObject partialMockForObject:[CWDataManager sharedInstance]];
    NSError * error = nil;
    [[[mockDataManager expect] andReturn:mockMessage] importMessageAtFilePath:mockUrl withError:((NSError __autoreleasing **)[OCMArg setTo:error])];
    
    //when
    [self.sut setZipURL:mockUrl];
    
    //should
    [self.mockSUT verify];
    [mockDataManager verify];
    
    //cleanup
    [mockDataManager stopMocking];
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

- (void)testShouldStartSetOpenerStateToPreviewWhenVideoLoads
{
    //given
    [[self.mockSUT expect] setOpenerState:CWOpenerPreview];
    
    //when
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
    
    //should
    [self.mockSUT verify];
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
    //given
    [self prepMessageItem];
    self.sut.activeMessage.startRecordingValue = 2;
    [[self.mockSUT expect] startReviewCountDown];
    //when
    [self.sut setOpenerState:CWOpenerReview];
    //should
    [self.mockSUT verify];
}

- (void)testShouldSetStateToReviewWhenOpenerStateIsSetToReview
{
    //given
    [self prepMessageItem];
    [[self.mockSUT expect] setOpenerState:CWOpenerReview];
    //when
    [self.sut setOpenerState:CWOpenerReview];
    //should
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
