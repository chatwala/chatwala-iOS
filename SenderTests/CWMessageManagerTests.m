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
#import "CWDataManager.h"

@interface CWMessageManagerTests : XCTestCase

@property (nonatomic) CWMessageManager *sut;
@property (nonatomic) id mockSut;
@property (nonatomic) id mockDataManager;

@end

@implementation CWMessageManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWMessageManager alloc] init];
    self.mockSut = [OCMockObject partialMockForObject:self.sut];
    self.mockDataManager = [OCMockObject partialMockForObject:[CWDataManager sharedInstance]];
}

- (void)tearDown
{
    [self.mockDataManager stopMocking];
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
    [[self.mockDataManager expect] importMessages:messages];
    
    // when
    self.sut.getMessagesSuccessBlock(mockOperation, responseObject);
    
    // should
    [self.mockDataManager verify];
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
    id toMakeWarningGoAway = [[[mockManager stub] andReturn:mockManager] initWithSessionConfiguration:OCMOCK_ANY];
    NSLog(@"%@",toMakeWarningGoAway);
    [[mockManager expect] downloadTaskWithRequest:OCMOCK_ANY progress:[OCMArg setTo:progress] destination:OCMOCK_ANY completionHandler:OCMOCK_ANY];
    
    //when
    [self.sut downloadMessageWithID:messageID progress:OCMOCK_ANY completion:OCMOCK_ANY];
    
    //should
    [mockManager verify];
    [mockManager stopMocking];
    
}

- (void) testDownloadURLDestinationBlock
{
    //given
    id mockResponse = [OCMockObject mockForClass:[NSURLResponse class]];
    [[[mockResponse stub] andReturn:@"mySuggestion"] suggestedFilename];
    NSURL * docDir = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    NSURL * expectedURL = [docDir URLByAppendingPathComponent:@"mySuggestion"];
    
    //when
    NSURL * actual = self.sut.downloadURLDestinationBlock(OCMOCK_ANY, mockResponse);
    
    //should
    XCTAssertEqualObjects(actual, expectedURL, @"download path should be expected dl path");
}

- (void) testDownloadTaskCompletionBlockFailedBecauseOfError
{
    //given
    NSURL * filePath = OCMOCK_ANY;
    NSError * error = OCMOCK_ANY;
    __block BOOL ranWithFailure = NO;
    CWMessageDownloadCompletionBlock messageCompletionBlock = ^void(BOOL success, NSURL *url)
    {
        if(!success)
        {
            ranWithFailure = YES;
        }
    };
    
    //when
    self.sut.downloadTaskCompletionBlock(OCMOCK_ANY, filePath, error, messageCompletionBlock);
    
    //should
    XCTAssertTrue(ranWithFailure, @"expecting to run with failure");
}

- (void) testDownloadTaskCompletionBlockFailedBecauseOfStatusCode
{
    //given
    NSHTTPURLResponse * response = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:404 HTTPVersion:nil headerFields:nil];
    NSURL * filePath = OCMOCK_ANY;
    NSError * error = nil;
    __block BOOL ranWithFailure = NO;
    CWMessageDownloadCompletionBlock messageCompletionBlock = ^void(BOOL success, NSURL *url)
    {
        if(!success)
        {
            ranWithFailure = YES;
        }
    };
    
    //when
    self.sut.downloadTaskCompletionBlock(response, filePath, error, messageCompletionBlock);
    
    //should
    XCTAssertTrue(ranWithFailure, @"expecting to run with failure");
}

- (void) testDownloadTaskCompletionBlockSucceeds
{
    //given
    NSHTTPURLResponse * response = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:200 HTTPVersion:nil headerFields:nil];
    NSURL * filePath = OCMOCK_ANY;
    NSError * error = nil;
    __block BOOL ranWithSuccess = NO;
    __block NSURL *actual = nil;
    CWMessageDownloadCompletionBlock messageCompletionBlock = ^void(BOOL success, NSURL *url)
    {
        if(success)
        {
            ranWithSuccess = YES;
        }
        actual = url;
    };
    
    //when
    self.sut.downloadTaskCompletionBlock(response, filePath, error, messageCompletionBlock);
    
    //should
    XCTAssertTrue(ranWithSuccess, @"expecting to run with Success");
    XCTAssertTrue([actual isEqual:filePath], @"expecting url to be pass throug");
}

- (void) testUploadMessage
{
    //given
    CWMessageItem * item = [[CWMessageItem alloc] init];
    id mockManager = [OCMockObject mockForClass:[AFURLSessionManager class]];
    [[[mockManager stub] andReturn:mockManager] alloc];
    id toMakeWarningGoAway = [[[mockManager stub] andReturn:mockManager] initWithSessionConfiguration:OCMOCK_ANY];
    NSLog(@"%@",toMakeWarningGoAway);
    [[mockManager expect] uploadTaskWithRequest:OCMOCK_ANY fromFile:item.zipURL progress:nil completionHandler:OCMOCK_ANY];

    //when
    [self.sut uploadMessage:item isReply:NO];
    
    //should
    [mockManager verify];
    
}


@end
