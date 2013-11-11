//
//  CWVideoPlayerTests.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWVideoPlayer.h"

@interface CWVideoPlayerTests : XCTestCase
@property (nonatomic,strong) CWVideoPlayer * sut;
@end

@implementation CWVideoPlayerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWVideoPlayer alloc]init];
}

- (void)tearDown
{
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



@end
