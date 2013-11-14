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

@interface CWOpenerViewController () <AVAudioPlayerDelegate,CWVideoPlayerDelegate>
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) CWMessageItem * messageItem;
@property (nonatomic,strong) NSTimer * responseCountdownTimer;
@property (nonatomic,assign) NSInteger responseCountdownTickCount;
- (void)onResponseCountdownTick:(NSTimer*)timer;
- (void)setupCameraView;
@end

@interface CWOpenerVCTests : XCTestCase
@property (nonatomic,strong) CWOpenerViewController * sut;
@property (nonatomic,strong) id mockSUT;
@property (nonatomic,strong) id mockPlayer;
@property (nonatomic,strong) id mockRecorder;
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
    
}

- (void)tearDown
{
    [self.mockSUT stopMocking];
    [self.mockRecorder stopMocking];
    [self.mockPlayer stopMocking];
    self.mockSUT = nil;
    self.mockPlayer = nil;
    self.mockRecorder = nil;
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

- (void)testShouldSetPlayerDelegateWhenViewWillAppear
{
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockPlayer stub]setVideoURL:mockUrl];
    
    [self.sut setMessageItem:[[CWMessageItem alloc] init]];
    [self.sut.messageItem setVideoURL:mockUrl];
    
    [[self.mockPlayer expect]setDelegate:self.sut];
    [self.sut viewWillAppear:NO];
    [self.mockPlayer verify];
}


- (void) testshouldInvokeSetupCameraWhenViewLoads {
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockPlayer stub]setVideoURL:mockUrl];
    
    [self.sut setMessageItem:[[CWMessageItem alloc] init]];
    [self.sut.messageItem setVideoURL:mockUrl];
    
    [[self.mockSUT expect]setupCameraView];
    [self.sut viewWillAppear:YES];
    [self.mockSUT verify];
}

- (void)testShouldSetRecorderDelegateWhenViewWillAppear
{
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockPlayer stub]setVideoURL:mockUrl];
    
    [self.sut setMessageItem:[[CWMessageItem alloc] init]];
    [self.sut.messageItem setVideoURL:mockUrl];
    
    [[self.mockRecorder expect]setDelegate:self.sut];
    [self.sut viewWillAppear:NO];
    [self.mockRecorder verify];
}

- (void)testShouldSetVideoUrlOnPlayerWhenViewWillAppear
{
    id mockUrl = [OCMockObject mockForClass:[NSURL class]];
    [[self.mockPlayer expect]setVideoURL:mockUrl];
    
    [self.sut setMessageItem:[[CWMessageItem alloc] init]];
    [self.sut.messageItem setVideoURL:mockUrl];
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





@end
