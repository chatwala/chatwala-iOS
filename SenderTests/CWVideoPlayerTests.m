//
//  CWVideoPlayerTests.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TestUtils.h"
#import "CWVideoPlayer.h"

#import "AVURLAsset+Spec.h"
#import "AVPlayer+Spec.h"
#import "AVPlayerItem+Spec.h"

@interface CWVideoPlayer ()
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
- (void)playerItemDidReachEnd:(NSNotification*)note;
- (void)setupPlayerItemWithAsset:(AVAsset*)asset;
- (void)setupPlayerWithAsset:(AVAsset*)asset;
@end


@interface CWVideoPlayerTests : XCTestCase
@property (nonatomic,strong) CWVideoPlayer * sut;
@property (nonatomic,strong) id mockDelegate;

@end

@implementation CWVideoPlayerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWVideoPlayer alloc]init];
    self.mockDelegate = [OCMockObject mockForProtocol:@protocol(CWVideoPlayerDelegate)];
    [self.sut setDelegate:self.mockDelegate];
}

- (void)tearDown
{
    self.mockDelegate = nil;
    self.sut = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExists
{
    XCTAssertNotNil(self.sut, @"should exist");
}


- (void)testShouldHaveVideoURLSetter
{
    XCTAssertTrue([self.sut respondsToSelector:@selector(setVideoURL:)], @"should have videoURL setter");
}

- (void)testShouldHaveStopMethod
{
    XCTAssertTrue([self.sut respondsToSelector:@selector(stop)], @"should have stop");
}


- (void)testShouldAddObserverToNotificationCenter
{
    id nc = [OCMockObject partialMockForObject:[NSNotificationCenter defaultCenter]];
    [[nc expect]addObserver:self.sut selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:OCMOCK_ANY];
    
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    [nc verify];
    [nc stopMocking];
}


- (void)testShouldSetupPlayerItem
{
    id mock = [OCMockObject partialMockForObject:self.sut];
    [[mock expect]setupPlayerItemWithAsset:OCMOCK_ANY];
    
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    [mock verify];
    [mock stopMocking];
}


- (void)testShouldAddObserverToPlayerItem
{
//    [self.sut setupPlayerItemWithAsset:OCMOCK_ANY];
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    XCTAssertNotNil([self.sut.playerItem observationInfo], @"should add observer to player item");
}


- (void)testShouldAddObserverToPlayer
{
    //    [self.sut setupPlayerItemWithAsset:OCMOCK_ANY];
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    XCTAssertNotNil([self.sut.player observationInfo], @"should add observer to player");
}


- (void)testShouldSetupPlayer
{
    id mock = [OCMockObject partialMockForObject:self.sut];
    [[mock expect]setupPlayerWithAsset:OCMOCK_ANY];
    
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    
    [mock verify];
    [mock stopMocking];
}




- (void)testShouldInvokeVideoPlayerDidLoadVideo
{
    [[self.mockDelegate expect]videoPlayerDidLoadVideo:self.sut];
    
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    
    [self.sut.playerItem setStatus:AVPlayerStatusReadyToPlay];
    [self.mockDelegate verify];
    

}

- (void)testShouldInvokeVideoPlayerFailedToLoadVideo
{
    [[self.mockDelegate expect]videoPlayerFailedToLoadVideo:self.sut withError:OCMOCK_ANY];
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"bad" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[] failureKeys:@[]];
    [self.mockDelegate verify];
}



@end
