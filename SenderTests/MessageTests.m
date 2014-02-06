//
//  MessageTests.m
//  Sender
//
//  Created by randall chatwala on 1/13/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Message.h"
#import "MocForTests.h"
#import "Message.h"
#import "CWMessageCell.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"
#import "User.h"
#import "Thread.h"
#import <SSZipArchive.h>
#import "CWUtility.h"

@interface MessageTests : XCTestCase

@property (nonatomic) Message * sut;

@end

@implementation MessageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.sut = [Message insertInManagedObjectContext:mocFactory.moc];
    
    self.sut.messageID = @"Some message ID";

}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDownloadChatwalaDataShouldStartThumbnailDownload
{
    //given
    self.sut.thumbnailPictureURL = @"http://chatwala-prod.azurewebsites.net/images/message_thumb.png";
    CWMessageCell * messageCell = [[CWMessageCell alloc] init];
    id mockImageView = [OCMockObject mockForClass:[UIImageView class]];
    [[mockImageView expect] setImageWithURLRequest:OCMOCK_ANY placeholderImage:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    messageCell.thumbView = mockImageView;
    id messageManagerMock = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[messageManagerMock stub] downloadMessageWithID:@"Some message ID" progress:OCMOCK_ANY completion:OCMOCK_ANY];

    //when
    [self.sut downloadChatwalaDataWithMessageCell:messageCell];
    
    //should
    [mockImageView verify];
    
    //cleanup
    [mockImageView stopMocking];
    [messageManagerMock stopMocking];
    
}

- (void)testDownloadChatwalaDataShouldStartMessageDownload
{
    //given
    id messageManagerMock = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[messageManagerMock expect] downloadMessageWithID:OCMOCK_ANY progress:OCMOCK_ANY completion:OCMOCK_ANY];
    //when
    [self.sut downloadChatwalaDataWithMessageCell:nil];
    
    //should
    [messageManagerMock verify];
    
    //cleanup
    [messageManagerMock stopMocking];
    
}

- (void)testToDictionaryWithDataFormatter
{
    //given
    NSDateFormatter * dateFormatter = [CWDataManager dateFormatter];
    NSError * error = nil;
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary * expected= @{
//                               @"download_state" : @0,
//                               @"viewed_state" : @0,
                               @"thread_index" : @1,
                               @"thread_id" : @"B515825C-F722-427A-AC01-044D9B739D17",
                               @"message_id" : @"9C545455-BBE7-4DE5-9208-AADEFB8EF674",
                               @"sender_id" : @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f",
                               @"recipient_id" : @"b838aef1-c804-b5b0-29ef-41b579350756",
                               @"timestamp" : @"2014-01-13T10:20:14Z",
                               @"start_recording" : @2.648333,
                               @"version_id" : appVersion,
                               };
    
    self.sut.messageID = @"9C545455-BBE7-4DE5-9208-AADEFB8EF674";
    self.sut.threadIndex = @1;
    self.sut.startRecording = @2.648333;
    self.sut.timeStamp = [dateFormatter dateFromString:@"2014-01-13T10:20:14Z"];
    User * sender = [User insertInManagedObjectContext:self.sut.managedObjectContext];
    sender.userID = @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f";
    self.sut.sender = sender;
    User * receiver = [User insertInManagedObjectContext:self.sut.managedObjectContext];
    receiver.userID = @"b838aef1-c804-b5b0-29ef-41b579350756";
    self.sut.recipient = receiver;
    Thread * thread = [Thread insertInManagedObjectContext:self.sut.managedObjectContext];
    thread.threadID = @"B515825C-F722-427A-AC01-044D9B739D17";
    self.sut.thread = thread;
    
    //when
    NSDictionary * actual = [self.sut toDictionaryWithDataFormatter:dateFormatter error:&error];
    
    //should
    XCTAssertEqualObjects([expected objectForKey:@"sender_id"], [actual objectForKey:@"sender_id"], @"expecting the sender Id to be formated correctly");
    XCTAssertEqualObjects(actual, expected, @"expecting dictionary to match");
    
    //cleanup
}

-(void)testExportZip
{
    //given
    id mockSSZipArchive = [OCMockObject mockForClass:[SSZipArchive class]];
    [[mockSSZipArchive expect] createZipFileAtPath:OCMOCK_ANY withContentsOfDirectory:OCMOCK_ANY];
    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video" withExtension:@"mp4"];
    self.sut.videoURL = videoURL;
    self.sut.zipURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"testZipFile"];

    //when
    [self.sut exportZip];

    //should

    [mockSSZipArchive verify];

    //cleanup
    [mockSSZipArchive stopMocking];

}

-(void)testExportZipShouldCallToJSONWIthDateFormatter
{
    //given
    id mockMessage = [OCMockObject partialMockForObject:self.sut];
    NSError *error = nil;
    [[mockMessage expect] toJSONWithDateFormatter:OCMOCK_ANY error:[OCMArg setTo:error]];

    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video" withExtension:@"mp4"];
    self.sut.videoURL = videoURL;
    self.sut.zipURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"testZipFile"];

    //when
    [self.sut exportZip];

    //should
    [mockMessage verify];


    //cleanup
    [mockMessage stopMocking];
}

-(void)testExportZipWritestMetaDataToFile
{
    //given
    id mockJSONData = [OCMockObject mockForClass:[NSData class]];
    
    NSError *error = nil;
    id mockMessage = [OCMockObject partialMockForObject:self.sut];
    [[[mockMessage stub] andReturn:mockJSONData] toJSONWithDateFormatter:OCMOCK_ANY error:[OCMArg setTo:error]];

    [[mockJSONData expect] writeToFile:OCMOCK_ANY atomically:YES];

    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video" withExtension:@"mp4"];
    self.sut.videoURL = videoURL;
    self.sut.zipURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"testZipFile"];

    //when
    [self.sut exportZip];

    //should
    [mockJSONData verify];

    //cleanup
    [mockMessage stopMocking];

}

-(void)testExportZipShouldCopyVideoURL
{
    //given

    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"video" withExtension:@"mp4"];
    self.sut.videoURL = videoURL;

    NSError* error = nil;

    id mockFileManager = [OCMockObject partialMockForObject:[NSFileManager defaultManager]];
    [[mockFileManager expect] copyItemAtPath:videoURL.path toPath:OCMOCK_ANY error:[OCMArg setTo:error]];

    self.sut.zipURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"testZipFile"];

    //when
    [self.sut exportZip];

    //should
    [mockFileManager verify];

    //cleanup
    [mockFileManager stopMocking];
}

-(void)testEMessageViewedStateReturnsCorrectValue
{
    //given
    eMessageViewedState expected = arc4random_uniform(eMessageViewedStateTotal);
    self.sut.viewedStateValue = expected;

    //when
    eMessageViewedState actual = self.sut.eMessageViewedState;

    //should
    XCTAssertEqual(actual, expected, @"eMessageViewedState did not return expected value.");

    //cleanup

}

-(void)testEmessageViewStateShouldSetValueWhenLargerThanExisting
{
    //given
    eMessageViewedState expected = arc4random_uniform(eMessageViewedStateTotal);
    eMessageViewedState existing = arc4random_uniform(expected);

    self.sut.viewedStateValue = existing;

    //when
    [self.sut setEMessageViewedState:expected];

    //should
    XCTAssertEqualObjects(self.sut.viewedState, @(expected), @"eMessageViewedState did not return expected value.");
}


-(void)testEmessageViewStateShouldNotSetValueWhenLessThanExisting
{
    //given
    eMessageViewedState existing = arc4random_uniform(eMessageViewedStateTotal - 1) + 1;
    eMessageViewedState newValue = arc4random_uniform(existing);

    self.sut.viewedStateValue = existing;

    //when
    [self.sut setEMessageViewedState:newValue];

    //should
    XCTAssertEqualObjects(self.sut.viewedState, @(existing), @"eMessageViewedState did not return expected value.");
}

-(void)testEMessageDownloadStateReturnsCorrectValue
{
    //given
    eMessageDownloadState expected = arc4random_uniform(eMessageDownloadStateTotal);
    self.sut.downloadStateValue = expected;

    //when
    eMessageDownloadState actual = self.sut.eDownloadState;

    //should
    XCTAssertEqual(actual, expected, @"eMessageDownloadState did not return expected value.");
}

-(void)testEMessageViewedStateSetsCorrectValue
{
    //given
    eMessageDownloadState existing = arc4random_uniform(eMessageDownloadStateTotal);
    eMessageDownloadState newValue = arc4random_uniform(eMessageDownloadStateTotal);
    self.sut.downloadStateValue = existing;

    //when
    [self.sut setEMessageDownloadState:newValue];

    //should
    XCTAssertEqual(self.sut.downloadState, @(newValue), @"eMessageDownloadState did not return expected value.");

    //cleanup
    
}

@end
