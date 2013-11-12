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
@end


@interface CWVideoPlayerTests : XCTestCase
@property (nonatomic,strong) CWVideoPlayer * sut;
@property (nonatomic,strong) id delegate;

@end

@implementation CWVideoPlayerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWVideoPlayer alloc]init];
    self.delegate = [OCMockObject mockForProtocol:@protocol(CWVideoPlayerDelegate)];
    [self.sut setDelegate:self.delegate];
}

- (void)tearDown
{
    self.delegate = nil;
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
}


- (void)testShouldInvokeVideoPlayerDidLoadVideo
{
    [[self.delegate expect]videoPlayerDidLoadVideo:self.sut];
    
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[@"tracks",@"playable",@"duration",@"streaming"] failureKeys:@[]];
    
    [self.sut.playerItem setStatus:AVPlayerStatusReadyToPlay];
    [self.delegate verify];
    

}

- (void)testShouldInvokeVideoPlayerFailedToLoadVideo
{
    [[self.delegate expect]videoPlayerFailedToLoadVideo:self.sut withError:OCMOCK_ANY];
    NSURL * videoURL = [[NSBundle mainBundle] URLForResource:@"bad" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];
    [self.sut.asset completeWithSuccessKeys:@[] failureKeys:@[]];
    [self.delegate verify];
}



@end
