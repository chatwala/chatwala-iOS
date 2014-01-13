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

@interface CWDataManagerTests : XCTestCase

@property (nonatomic) CWDataManager * sut;
@property (nonatomic) id mockSut;
@property (nonatomic) NSArray * validMessageImport;

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

    self.validMessageImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @1389282510,  @"sender": @"senderID_io433ni2o4nsdnvc", @"thread":@"somethread idb2idboiwdbsdf"}];
    
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
    NSError * error = [self.sut importMessages:self.validMessageImport];
    
    //should
    XCTAssertNil(error, @"not expecting an error");
}

- (void) testImportMessagesShouldCallFindMessages
{
    //given
    [[self.mockSut expect] findMessageByMessageID:OCMOCK_ANY];
    
    //when
    NSError * error = [self.sut importMessages:self.validMessageImport];
    
    //should
    [self.mockSut verify];
    XCTAssertNil(error, @"not expecting an error");
    
}

- (void) testImportCreatesSomeMessages
{
    //given
    
    //when
    NSError * error = [self.sut importMessages:self.validMessageImport];
    
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
    [self.sut importMessages:self.validMessageImport];
    
    //should
    [self.mockSut verify];
}

- (void) testImportMessagesShouldCallCreateThread
{
    //given
    [[self.mockSut expect] createThreadWithID:OCMOCK_ANY];
    
    //when
    [self.sut importMessages:self.validMessageImport];
    
    //should
    [self.mockSut verify];
}

- (void) testFindMessageByMessageID
{
    //given
    [self.sut importMessages:self.validMessageImport];
    
    
    //when
    Message * actual = [self.sut findMessageByMessageID:@"foo"];
    
    //should
    XCTAssertNotNil(actual, @"expecting to find a message");
    XCTAssertEqualObjects(@"someURL", actual.messageURL, @"expecting messageURL to match");
    
}


- (void) testFindMessageByMessageIDShouldNotFindMessageWhenNoneExists
{
    //given
    [self.sut importMessages:self.validMessageImport];
    
    
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
    self.sut.localUser = [User insertInManagedObjectContext:self.sut.moc];
    Message * item = [Message insertInManagedObjectContext:self.sut.moc];
    id mockItem = [OCMockObject partialMockForObject:item];
    [[mockItem expect] downloadChatwalaDataWithMessageCell:OCMOCK_ANY];
    
    [self.sut.localUser addMessagesReceivedObject:item];
    
    //when
    [self.sut downloadAllMessageChatwalaData];
    
    //should
    [mockItem verify];
    
    //cleanup
    [mockItem stopMocking];
}



@end
