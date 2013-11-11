//
//  CWVideoPlayerViewTests.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import "CWVideoPlayerView.h"


@interface CWVideoPlayerViewTests : XCTestCase
@property (nonatomic,strong) CWVideoPlayerView * sut;
@end

@implementation CWVideoPlayerViewTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWVideoPlayerView alloc]init];
}

- (void)tearDown
{
    self.sut = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testLayerClassIsAVPlayerClass
{
    XCTAssertTrue([self.sut.layer isKindOfClass:[AVPlayerLayer class]], @"layer class should be AVPlayerLayer");
}

- (void)testSettingPlayer
{
    AVPlayer * player = [AVPlayer playerWithURL:nil];
    [self.sut setPlayer:player];
    XCTAssertTrue([player isEqual:self.sut.player], @"players should match");
}

- (void)testSettingVideoFillMode
{
    AVPlayer * player = [AVPlayer playerWithURL:nil];
    [self.sut setPlayer:player];
    [self.sut setVideoFillMode:@"something"];
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)self.sut.layer;
    
    XCTAssertTrue([playerLayer.videoGravity isEqualToString:@"something"], @"video gravity should match");
}
@end
