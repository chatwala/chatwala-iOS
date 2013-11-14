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


@interface CWOpenerViewController () <AVAudioPlayerDelegate,CWVideoPlayerDelegate>
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
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

- (void)testShouldSetPlayerDelegateWhenViewWillAppear
{
    [[self.mockPlayer expect]setDelegate:self.sut];
    [self.sut viewWillAppear:NO];
    [self.mockPlayer verify];
}

- (void) testShouldAddVideoPlayerViewWhenVideoIsReady {
    
    id mockPlaybackView = [OCMockObject partialMockForObject:self.sut.playbackView];
    [[mockPlaybackView expect]addSubview:self.sut.player.playbackView];
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
    [mockPlaybackView verify];
    [mockPlaybackView stopMocking];
    
}


@end
