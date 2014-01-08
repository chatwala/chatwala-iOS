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

@end

@implementation CWMessageManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWMessageManager alloc] init];
}

- (void)tearDown
{
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

@end
