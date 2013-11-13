//
//  CWReviewVCTests.m
//  Sender
//
//  Created by Khalid on 11/13/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWReviewViewController.h"
#import "CWVideoManager.h"



@interface CWReviewViewController ()<CWVideoPlayerDelegate>
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@end

@interface CWReviewVCTests : XCTestCase
@property (nonatomic,strong) CWReviewViewController * sut;
@property (nonatomic,strong) id mockSUT;
@property (nonatomic,strong) id mockRecorder;
@property (nonatomic,strong) id mockPlayer;
@end

@implementation CWReviewVCTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWReviewViewController alloc]init];
    [self.sut view];
    self.mockSUT = [OCMockObject partialMockForObject:self.sut];
    self.mockPlayer = [OCMockObject partialMockForObject:self.sut.player];
    self.mockRecorder = [OCMockObject partialMockForObject:self.sut.recorder];
}

- (void)tearDown
{
    [self.mockSUT stopMocking];
    [self.mockPlayer stopMocking];
    [self.mockRecorder stopMocking];
    self.sut = nil;
    self.mockSUT = nil;
    self.mockPlayer = nil;
    self.mockRecorder = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExists
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testHasPreviewView
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(previewView)];
    XCTAssertTrue(isTrue, @"should have preview view");
}

- (void)testHasRecordAgainButton
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(recordAgainButton)];
    XCTAssertTrue(isTrue, @"should have record button");
}


- (void)testHasSendButton
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(sendButton)];
    XCTAssertTrue(isTrue, @"should have send button");
}


- (void)testRespondsToOnRecordAgain
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(onRecordAgain:)];
    XCTAssertTrue(isTrue, @"should respond to onRecordAgain:");
}

- (void)testRespondsToOnSend
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(onSend:)];
    XCTAssertTrue(isTrue, @"should respond to onSend:");
}

- (void)testPlayerDelegateShouldSetWhenViewWillAppear
{
    [[self.mockPlayer expect]setDelegate:self.sut];
    [self.sut viewWillAppear:NO];
    [self.mockPlayer verify];
}


- (void)testPlayerVideoUrlIsSetWhenViewAppears
{
    [[self.mockPlayer expect]setVideoURL:OCMOCK_ANY];
    [self.sut viewDidAppear:NO];
    [self.mockPlayer verify];
}


- (void)testShouldPlayVideoWhenItLoads
{
    [[self.mockPlayer expect]playVideo];
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
    [self.mockPlayer verify];
}


- (void)testShouldReplayVideoWhenItFinishes
{
    [[self.mockPlayer expect]replayVideo];
}


@end
