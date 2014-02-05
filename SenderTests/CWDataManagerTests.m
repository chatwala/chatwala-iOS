//
//  CWDataManagerTests.m
//  Sender
//
//  Created by randall chatwala on 1/9/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CWDataManager.h"
#import "MocForTests.h"
#import "Message.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"

@interface CWDataManagerTests : XCTestCase

@property (nonatomic) CWDataManager * sut;
@property (nonatomic) id mockSut;
@property (nonatomic) NSArray * validMessagesImport;

@end

@implementation CWDataManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWDataManager alloc] init];
 
    self.mockSut = [OCMockObject partialMockForObject:self.sut];
    
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.sut.moc = mocFactory.moc;

    self.validMessagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @1389282510,  @"sender": @"senderID_io433ni2o4nsdnvc", @"thread":@"somethread idb2idboiwdbsdf"}];
    
}

- (void)tearDown
{
    [self.mockSut stopMocking];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testImportMessagesShouldReturnErrorWithBadData
{
    //given
    NSArray * messagesImport = @[@"blah"];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNotNil(error, @"expecting an error");
}

- (void)testImportMessagesShouldReturnErrorWithBadData2
{
    //given
    NSArray * messagesImport = @[@{@"blah":@"foo"}];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNotNil(error, @"expecting an error");
}

- (void) testImportMessagesShouldNotReturnErrorWithValidData
{
    //given
    
    //when
    NSError * error = [self.sut importMessages:self.validMessagesImport];
    
    //should
    XCTAssertNil(error, @"not expecting an error");
}

- (void) testImportMessagesShouldCallFindMessages
{
    //given
    [[self.mockSut expect] findMessageByMessageID:OCMOCK_ANY];
    
    //when
    NSError * error = [self.sut importMessages:self.validMessagesImport];
    
    //should
    [self.mockSut verify];
    XCTAssertNil(error, @"not expecting an error");
    
}

- (void) testImportCreatesSomeMessages
{
    //given
    
    //when
    NSError * error = [self.sut importMessages:self.validMessagesImport];
    
    //should
    XCTAssertNil(error, @"not expecting an error");
    Message * actual = [self.sut findMessageByMessageID:@"foo"];
    XCTAssertNotNil(actual, @"expecting to find a newly created message");
    
}

- (void) testImportMessagesShouldCallCreateUsers
{
    //given
    [[self.mockSut expect] createUserWithID:OCMOCK_ANY];
    
    //when
    [self.sut importMessages:self.validMessagesImport];
    
    //should
    [self.mockSut verify];
}

- (void) testImportMessagesShouldCallCreateThread
{
    //given
    [[self.mockSut expect] createThreadWithID:OCMOCK_ANY];
    
    //when
    [self.sut importMessages:self.validMessagesImport];
    
    //should
    [self.mockSut verify];
}

- (void) testFindMessageByMessageID
{
    //given
    [self.sut importMessages:self.validMessagesImport];
    
    
    //when
    Message * actual = [self.sut findMessageByMessageID:@"foo"];
    
    //should
    XCTAssertNotNil(actual, @"expecting to find a message");
    XCTAssertEqualObjects(@"someURL", actual.messageURL, @"expecting messageURL to match");
    
}


- (void) testFindMessageByMessageIDShouldNotFindMessageWhenNoneExists
{
    //given
    [self.sut importMessages:self.validMessagesImport];
    
    
    //when
    Message * actual = [self.sut findMessageByMessageID:@"bar"];
    
    //should
    XCTAssertNil(actual, @"expecting to NOT find a message");
    [actual isKindOfClass:[Message class]];
}


- (void) testFindThreadByThreadID
{
    //given
    NSString * threadID = @"wintoiewoiedsfdfio";
    Thread * expected = [self.sut createThreadWithID:threadID];
    NSError * error = nil;
    [self.sut.moc save:&error];
    
    //when
    Thread * actual = [self.sut findThreadByThreadID:threadID];
    
    //should
    XCTAssertNil(error, @"not expecting erro on save");
    XCTAssertEqualObjects(actual, expected, @"expecting threads to match");
    
}

- (void) testFindThreadByThreadIDShouldNotFindThreadWhenNoneExists
{
    //given
    NSString * threadID = @"wintoiewoiedsfdfio";
    Thread * expected = [self.sut createThreadWithID:threadID];
    NSError * error = nil;
    [self.sut.moc save:&error];
    
    //when
    Thread * actual = [self.sut findThreadByThreadID:@"Some other key"];
    
    //should
    XCTAssertNil(error, @"not expecting error on save");
    XCTAssertNotEqualObjects(actual, expected, @"expecting threads to match");
    
}

- (void) testCreateThread
{
    //given
    
    //when
    Thread * actual = [self.sut createThreadWithID:@";lndafn;aoi"];
    
    //should
    XCTAssertNotNil(actual, @"expecting a thread to be created");
    XCTAssertEqualObjects(actual.threadID, @";lndafn;aoi", @"expecting new thread to have matching userID");
}

- (void) testCreateUser
{
    //given
    
    //when
    User * actual = [self.sut createUserWithID:@"foobar"];
    
    //should
    XCTAssertNotNil(actual, @"expecting a user to be created");
    XCTAssertEqualObjects(actual.userID, @"foobar", @"expecting new user to have matching userID");
}


- (void) testFindUserByUserID
{
    //given
    NSString * userID = @"wintoiewoiedsfdfio";
    User * expected = [self.sut createUserWithID:userID];
    NSError * error = nil;
    [self.sut.moc save:&error];
    
    //when
    User * actual = [self.sut findUserByUserID:userID];
    
    //should
    XCTAssertNil(error, @"not expecting erro on save");
    XCTAssertEqualObjects(actual, expected, @"expecting users to match");
    
}

- (void) testFindUserByUserIDShouldNotFindUserWhenNoneExists
{
    //given
    NSString * userID = @"wintoiewoiedsfdfio";
    User * expected = [self.sut createUserWithID:userID];
    NSError * error = nil;
    [self.sut.moc save:&error];
    
    //when
    User * actual = [self.sut findUserByUserID:@"Some other key"];
    
    //should
    XCTAssertNil(error, @"not expecting error on save");
    XCTAssertNotEqualObjects(actual, expected, @"expecting users to match");
    
}

- (void) testDownloadAllMessageData
{
    //given
    id mockUserManger = [OCMockObject partialMockForObject:[CWUserManager sharedInstance]];
    User * localUser = [User insertInManagedObjectContext:self.sut.moc];
    [[[mockUserManger stub] andReturn:localUser] localUser];
    
    Message * item = [Message insertInManagedObjectContext:self.sut.moc];
    id mockItem = [OCMockObject partialMockForObject:item];
    [[mockItem expect] downloadChatwalaDataWithMessageCell:OCMOCK_ANY];
    [localUser addMessagesReceivedObject:item];
    
    //when
    [self.sut downloadAllMessageChatwalaData];
    
    //should
    [mockItem verify];
    
    //cleanup
    [mockItem stopMocking];
}

- (void) testCreateMessageWithDictionaryStartTime
{
    //given
    NSError * error = nil;
    NSNumber * startRecordingTime = @(arc4random_uniform(10));
    NSDictionary * jsonDictionary = @{
        @"thread_index" : @1,
        @"thread_id" : @"B515825C-F722-427A-AC01-044D9B739D17",
        @"message_id" : @"9C545455-BBE7-4DE5-9208-AADEFB8EF674",
        @"sender_id" : @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f",
        @"version_id" : @"1.0",
        @"recipient_id" : @"b838aef1-c804-b5b0-29ef-41b579350756",
        @"timestamp" : @"2014-01-13T10:20:14Z",
        @"start_recording" : startRecordingTime
    };
    
    //when
    Message * actual = [self.sut createMessageWithDictionary:jsonDictionary error:&error];
    
    
    //should
    XCTAssertEqualObjects(startRecordingTime, actual.startRecording, @"expecting start recording time to be the same");
}

- (void) testCreateMessageWithDictionaryTimeStamp
{
    //given
    NSError * error = nil;
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSince1970:1391467364];
    NSString * timeStampString = [NSString stringWithFormat:@"%f", [timeStamp timeIntervalSince1970]];
    NSDictionary * jsonDictionary = @{
                                      @"thread_index" : @1,
                                      @"thread_id" : @"B515825C-F722-427A-AC01-044D9B739D17",
                                      @"message_id" : @"9C545455-BBE7-4DE5-9208-AADEFB8EF674",
                                      @"sender_id" : @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f",
                                      @"version_id" : @"1.0",
                                      @"recipient_id" : @"b838aef1-c804-b5b0-29ef-41b579350756",
                                      @"timestamp" : timeStampString,
                                      @"start_recording" : @2.648333,
                                      };
    //when
    Message * actual = [self.sut createMessageWithDictionary:jsonDictionary error:&error];
    
    
    //should
    XCTAssertTrue([actual.timeStamp isEqualToDate:timeStamp], @"expecting time stamp to be the same");
}

- (void) testCreateMessageWithDictionaryTimeStampInMiliseconds
{
    //given
    NSError * error = nil;
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSince1970:1391467364.156];
    NSString * timeStampString = @"1391467364156";
    NSDictionary * jsonDictionary = @{
                                      @"thread_index" : @1,
                                      @"thread_id" : @"B515825C-F722-427A-AC01-044D9B739D17",
                                      @"message_id" : @"9C545455-BBE7-4DE5-9208-AADEFB8EF674",
                                      @"sender_id" : @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f",
                                      @"version_id" : @"1.0",
                                      @"recipient_id" : @"b838aef1-c804-b5b0-29ef-41b579350756",
                                      @"timestamp" : timeStampString,
                                      @"start_recording" : @2.648333,
                                      };
    //when
    Message * actual = [self.sut createMessageWithDictionary:jsonDictionary error:&error];
    
    
    //should
    XCTAssertTrue([actual.timeStamp isEqualToDate:timeStamp], @"expecting time stamp to be the same");
}


- (void) testCreateMessageWithDictionary
{
    //given
    NSError * error = nil;
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:10];
    NSString * timeStampString = [NSString stringWithFormat:@"%f", [timeStamp timeIntervalSince1970]];
    NSDictionary * jsonDictionary = @{
                                      @"thread_index" : @1,
                                      @"thread_id" : @"B515825C-F722-427A-AC01-044D9B739D17",
                                      @"message_id" : @"9C545455-BBE7-4DE5-9208-AADEFB8EF674",
                                      @"sender_id" : @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f",
                                      @"version_id" : @"1.0",
                                      @"recipient_id" : @"b838aef1-c804-b5b0-29ef-41b579350756",
                                      @"timestamp" : timeStampString,
                                      @"start_recording" : @2.648333,
                                      };
    //when
    Message * actual = [self.sut createMessageWithDictionary:jsonDictionary error:&error];
    
    
    //should
    XCTAssertEqualObjects(actual.messageID, @"9C545455-BBE7-4DE5-9208-AADEFB8EF674", @"expecting the message ID to be set");
    XCTAssertEqualObjects(actual.threadIndex, @1, @"expecting the thread index to tbe set");
    XCTAssertEqualObjects(actual.thread.threadID, @"B515825C-F722-427A-AC01-044D9B739D17", @"expecting the thread to be set");
    XCTAssertEqualObjects(actual.sender.userID, @"0b47ffe0-a491-3599-6ef2-e4cc4b03b22f", @"expecting the sender to be set");
    XCTAssertEqualObjects(actual.recipient.userID, @"b838aef1-c804-b5b0-29ef-41b579350756", @"expecting the receiver to be set");
    XCTAssertEqualObjects(actual.startRecording, @2.648333, @"expecting start recording to be set");
}

- (void) testCreateMessageWithSender
{
    //given
    User * sender = [User insertInManagedObjectContext:self.sut.moc];
    
    //when
    Message * actual = [self.sut createMessageWithSender:sender inResponseToIncomingMessage:nil];
    
    //should
    XCTAssertNotNil(actual.thread, @"expecting the thread to be something");
    XCTAssertNotNil(actual.timeStamp, @"expecting the time stamp to be set");
    XCTAssertEqualObjects(actual.threadIndex, @0, @"expecting the thread index to be 0");
    XCTAssertEqualObjects(actual.sender, sender, @"expecting the sender to be set");
    
}

- (void) testCreateMessageWithSenderWithIncomingMessage
{
    //given
    User * sender = [User insertInManagedObjectContext:self.sut.moc];
    User * recipient = [User insertInManagedObjectContext:self.sut.moc];
    Message * incomingMessage = [Message insertInManagedObjectContext:self.sut.moc];
    incomingMessage.threadIndex = @8;
    incomingMessage.sender = recipient;
    
    //when
    Message * actual = [self.sut createMessageWithSender:sender inResponseToIncomingMessage:incomingMessage];
    
    //should
    XCTAssertEqualObjects(actual.thread, incomingMessage.thread, @"expecting the thread to be something");
    XCTAssertNotNil(actual.timeStamp, @"expecting the time stamp to be set");
    XCTAssertEqualObjects(actual.threadIndex, @9, @"expecting the thread index to be 0");
    XCTAssertEqualObjects(actual.sender, sender, @"expecting the sender to be set");
    XCTAssertEqualObjects(actual.recipient, recipient, @"expecting the recipient to be set");
}

@end
