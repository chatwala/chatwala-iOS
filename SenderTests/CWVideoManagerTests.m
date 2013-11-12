//
//  CWVideoManagerTests.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#import "CWVideoManager.h"
#import "CWVideoPlayer.h"
#import "CWVideoRecorder.h"

@interface AVURLAsset (Test)
- (void)succeed;
- (void)fail;
@end

static char COMPLETION_KEY;
@implementation AVURLAsset (Test)

- (void)loadValuesAsynchronouslyForKeys:(NSArray *)keys completionHandler:(void (^)(void))handler
{
    objc_setAssociatedObject(self, &COMPLETION_KEY, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)completeWithSuccessKeys:(NSArray *)successKeys failureKeys:(NSArray *)failureKeys {
    void (^callback)(void) = objc_getAssociatedObject(self, &COMPLETION_KEY);
    callback();
}

@end

@interface CWVideoManagerTests : XCTestCase
@property (nonatomic,strong) CWVideoManager * sut;
@end

@implementation CWVideoManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [CWVideoManager sharedManager];
}

- (void)tearDown
{
    self.sut = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testShouldExist
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testShouldHaveVideoRecorder
{
    XCTAssertNotNil(self.sut.recorder, @"should have recorder");
    XCTAssertTrue([self.sut.recorder isKindOfClass:[CWVideoRecorder class]], @"should be CWVideoRecorder");
}


- (void)testShouldHaveVideoPlayer
{
    XCTAssertNotNil(self.sut.player, @"should have player");
    XCTAssertTrue([self.sut.player isKindOfClass:[CWVideoPlayer class]], @"should be CWVideoPlayer");
}


@end
