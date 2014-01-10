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

@interface CWDataManagerTests : XCTestCase

@property (nonatomic) CWDataManager * sut;
@property (nonatomic) id mockSut;


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
    NSArray * messagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @"2013-09-29T18:46:19"}];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNil(error, @"not expecting an error");
}

- (void) testImportMessagesShouldCallFindMessages
{
    //given
    NSArray * messagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @"2013-09-29T18:46:19"}];
    [[self.mockSut expect] findMessageByMessageID:OCMOCK_ANY];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    [self.mockSut verify];
    XCTAssertNil(error, @"not expecting an error");
    
}

- (void) testImportCreatesSomeMessages
{
    //given
    NSArray * messagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @"2013-09-29T18:46:19"}];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNil(error, @"not expecting an error");
    Message * actual = [self.sut findMessageByMessageID:@"foo"];
    XCTAssertNotNil(actual, @"expecting to find a newly created message");
    
}

- (void) testFindMessageByMessageID
{
    //given
    NSArray * messagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @"2013-09-29T18:46:19"}];
    [self.sut importMessages:messagesImport];
    
    
    //when
    Message * actual = [self.sut findMessageByMessageID:@"foo"];
    
    //should
    XCTAssertNotNil(actual, @"expecting to find a message");
    XCTAssertEqualObjects(@"someURL", actual.messageURL, @"expecting messageURL to match");
    
}

- (void) testFindMessageByMessageIDShouldNotFindMessageWhenNoneExists
{
    //given
    NSArray * messagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @"2013-09-29T18:46:19"}];
    [self.sut importMessages:messagesImport];
    
    
    //when
    Message * actual = [self.sut findMessageByMessageID:@"bar"];
    
    //should
    XCTAssertNil(actual, @"expecting to NOT find a message");
    
    [actual isKindOfClass:[Message class]];
}

@end
