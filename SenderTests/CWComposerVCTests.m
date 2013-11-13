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

@interface CWComposerViewController ()
@property (nonatomic,strong) CWFeedbackViewController * feedbackVC;
@property (nonatomic,strong) CWReviewViewController * reviewVC;
@property (nonatomic,strong) NSTimer * recordTimer;
@property (nonatomic,assign) NSInteger tickCount;
- (void)startRecording;
- (void)stopRecording;
@end

@interface CWComposerVCTests : XCTestCase
@property (nonatomic,strong) CWComposerViewController * sut;
@property (nonatomic,strong) id mockVideoManager;
@property (nonatomic,strong) id mockRecorder;
@end

@implementation CWComposerVCTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWComposerViewController alloc]init];
    self.mockVideoManager = [OCMockObject partialMockForObject:[CWVideoManager sharedManager]];
    self.mockRecorder = [OCMockObject partialMockForObject:[[CWVideoManager sharedManager] recorder]];
}

- (void)tearDown
{
    
    self.sut = nil;
    [self.mockVideoManager stopMocking];
    self.mockVideoManager = nil;
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
    [[self.mockRecorder expect]startRecording];
    [self.sut viewDidAppear:NO];
}

- (void)testShouldSetTickCountToMaxWhenRecordingStarts
{
    id mockSUT = [OCMockObject partialMockForObject:self.sut];
    [[mockSUT expect]setTickCount:MAX_RECORD_TIME];
    [self.sut startRecording];
    [mockSUT stopMocking];
}




@end
