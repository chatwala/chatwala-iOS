//
//  CWMessageItemTests.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWMessageItem.h"


@interface CWMessageItemTests : XCTestCase
@property (nonatomic,strong) CWMessageItem * sut;
@end

@implementation CWMessageItemTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWMessageItem alloc]init];
    
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExists
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testShouldHaveMetadata
{
    XCTAssertNotNil(self.sut.metadata, @"should have metadata");
}

- (void)testExportCreatesZip
{
    
    NSURL * videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video" withExtension:@"mp4"];
    [self.sut setVideoURL:videoURL];

    [self.sut exportZip];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL zipExists = [fm fileExistsAtPath:self.sut.zipURL.path];
    XCTAssertTrue(zipExists, @"zip should have been created");
}

- (void)testExtractUnzipArchive
{
    //given that we have a zipped message
    NSURL * videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video" withExtension:@"mp4"];
    CWMessageItem * zippedMessageItem = [[CWMessageItem alloc] init];
    
    [zippedMessageItem setVideoURL:videoURL];
    [zippedMessageItem exportZip];
    
    [self.sut setZipURL:zippedMessageItem.zipURL];
    [self.sut extractZip];
    
    XCTAssertEqualObjects(self.sut.metadata.messageId, zippedMessageItem.metadata.messageId, @"messageId should match");
    XCTAssertEqualWithAccuracy([zippedMessageItem.metadata.timestamp timeIntervalSince1970], [self.sut.metadata.timestamp timeIntervalSince1970], 1, @"timestamp should match");
    XCTAssertEqualObjects(self.sut.metadata.senderId, zippedMessageItem.metadata.senderId, @"senderId should match");
    XCTAssertEqualObjects(self.sut.metadata.recipientId, zippedMessageItem.metadata.recipientId, @"recipientId should match");
    XCTAssertEqualObjects(self.sut.metadata.threadId, zippedMessageItem.metadata.threadId, @"threadId should match");
    XCTAssertEqual(self.sut.metadata.threadIndex, zippedMessageItem.metadata.threadIndex, @"threadIndex should match");
    XCTAssertEqual(self.sut.metadata.startRecording, zippedMessageItem.metadata.startRecording, @"startRecording should match");
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL zipExists = [fm fileExistsAtPath:self.sut.videoURL.path];
    XCTAssertTrue(zipExists, @"video file should exist");
    
    
}


@end
