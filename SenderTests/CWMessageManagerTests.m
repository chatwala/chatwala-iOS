//
//  CWMessageManagerTests.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CWMessageManager.h"

@interface CWMessageManagerTests : XCTestCase

@property (nonatomic) CWMessageManager *sut;
@property (nonatomic) id mockSut;

@end

@implementation CWMessageManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWMessageManager alloc] init];
    self.mockSut = [OCMockObject partialMockForObject:self.sut];
}

- (void)tearDown
{
    [self.mockSut stopMocking];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testGetMessagesShouldRequestMessagesWithKey
{
    //given
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockUserDefaults stub] andReturn:@"someUserId"] valueForKey:@"CHATWALA_USER_ID"];
    
    id mockManager = [OCMockObject mockForClass:[AFHTTPRequestOperationManager class]];
    [[[mockManager stub] andReturn:mockManager] manager];
    [[mockManager expect] setRequestSerializer:OCMOCK_ANY];
    [[mockManager expect] GET:OCMOCK_ANY parameters:nil success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    [self.sut getMessagesWithCompletionOrNil:OCMOCK_ANY];
    
    //should
    [mockManager verify];
    
    //cleanup
    [mockManager stopMocking];
    [mockUserDefaults stopMocking];
}

- (void)testGetMessagesSuccessBlock
{
    // given
    id mockOperation = [OCMockObject mockForClass:[AFHTTPRequestOperation class]];
    id messages = @[@"randomThingInHere"];
    id mockMessages = [OCMockObject partialMockForObject:messages];
    [[mockMessages stub] writeToURL:OCMOCK_ANY atomically:YES];
    NSDictionary * responseObject = @{@"messages": messages};
    
    // when
    self.sut.getMessagesSuccessBlock(mockOperation, responseObject);
    
    // should
    XCTAssertEqual(messages, self.sut.messages, @"expecting messages to be set");
    // cleanup
    [mockMessages stopMocking];
}

- (void)testGetMessagesSuccessBlockShouldPostNotification
{
    // given
    id messages = @[@"randomThingInHere"];
    id mockMessages = [OCMockObject partialMockForObject:messages];
    [[mockMessages stub] writeToURL:OCMOCK_ANY atomically:YES];
    NSDictionary * responseObject = @{@"messages": messages};
    id mockNC = [OCMockObject partialMockForObject:NC];
    [[mockNC expect] postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];

    // when
    self.sut.getMessagesSuccessBlock(OCMOCK_ANY, responseObject);
    
    // should
    [mockNC verify];
    
    // cleanup
    [mockNC stopMocking];
    
}

- (void)testGetMessagesSuccessBlockShouldNotNilMessages
{
    // given
    id messages = @[@"randomThingInHere"];
    NSDictionary * responseObject = @{@"bad_key": messages};
    self.sut.messages = messages;
    
    // when
    self.sut.getMessagesSuccessBlock(OCMOCK_ANY, responseObject);
    
    // should
    XCTAssertEqual(messages, self.sut.messages, @"expecting messages to be the same");
    
    // cleanup

}


- (void)testGetMessagesFailureBlock
{
    // given
    id mockNC = [OCMockObject partialMockForObject:NC];
    [[mockNC expect] postNotificationName:@"MessagesLoadFailed" object:nil userInfo:nil];
    // when
    self.sut.getMessagesFailureBlock(OCMOCK_ANY, OCMOCK_ANY);
    
    // should
    [mockNC verify];
    
    // cleanup
    [mockNC stopMocking];
}

- (void) testDownloadMessage
{
    //given
    NSString * messageID = @"someMessageID";
    NSProgress * progress = OCMOCK_ANY;
    id mockManager = [OCMockObject mockForClass:[AFURLSessionManager class]];
    [[[mockManager stub] andReturn:mockManager] alloc];
    [[[mockManager stub] andReturn:mockManager] initWithSessionConfiguration:OCMOCK_ANY];
    [[mockManager expect] downloadTaskWithRequest:OCMOCK_ANY progress:[OCMArg setTo:progress] destination:OCMOCK_ANY completionHandler:OCMOCK_ANY];
    
    //when
    [self.sut downloadMessageWithID:messageID progress:OCMOCK_ANY completion:OCMOCK_ANY];
    
    //should
    [mockManager verify];
    [mockManager stopMocking];
    
}

@end
