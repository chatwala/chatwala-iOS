//
//  UserTests.m
//  Sender
//
//  Created by randall chatwala on 1/13/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "User.h"
#import "MocForTests.h"
#import "Message.h"


@interface UserTests : XCTestCase

@property (nonatomic) User * sut;

@end

@implementation UserTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.sut = [User insertInManagedObjectContext:mocFactory.moc];

}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testInboxMessagesShouldReturnDataOrderedMessages
{
    //given
    Message * message1 = [Message insertInManagedObjectContext:self.sut.managedObjectContext];
    message1.timeStamp = [NSDate date];
    [message1 setEMessageDownloadState:eMessageDownloadStateDownloaded];
    [self.sut addMessagesReceivedObject:message1];
    Message * message2 = [Message insertInManagedObjectContext:self.sut.managedObjectContext];
    message2.timeStamp = [NSDate dateWithTimeIntervalSinceNow:10];
    [message2 setEMessageDownloadState:eMessageDownloadStateDownloaded];
    [self.sut addMessagesReceivedObject:message2];
    NSOrderedSet * expected = [NSOrderedSet orderedSetWithObjects:message2, message1, nil];
    
    //when
    NSOrderedSet * actual = [self.sut inboxMessages];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"expecting the order of the messages to be matching");
    
}


- (void)testInboxMessagesShouldReturnDataOrderedMessagesInsertOrderDifferent
{
    //given
    Message * message2 = [Message insertInManagedObjectContext:self.sut.managedObjectContext];
    message2.timeStamp = [NSDate dateWithTimeIntervalSinceNow:10];
    [message2 setEMessageDownloadState:eMessageDownloadStateDownloaded];
    [self.sut addMessagesReceivedObject:message2];
    Message * message1 = [Message insertInManagedObjectContext:self.sut.managedObjectContext];
    message1.timeStamp = [NSDate date];
    [message1 setEMessageDownloadState:eMessageDownloadStateDownloaded];
    [self.sut addMessagesReceivedObject:message1];
    NSOrderedSet * expected = [NSOrderedSet orderedSetWithObjects:message2, message1, nil];
    
    //when
    NSOrderedSet * actual = [self.sut inboxMessages];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"expecting the order of the messages to be matching");
    
}

@end
