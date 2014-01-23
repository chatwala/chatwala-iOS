//
//  CWMenuViewControllerTests.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CWInboxViewController.h"
#import "CWMessageManager.h"

@interface CWMenuViewControllerTests : XCTestCase

@property (nonatomic) CWInboxViewController * sut;

@end

@implementation CWMenuViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWInboxViewController alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testViewDidLoadShouldGetNewMessages
{
    //given
    id mockMessageManager = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[mockMessageManager expect] getMessagesForUser:OCMOCK_ANY withCompletionOrNil:OCMOCK_ANY];
    
    //when
    [self.sut viewDidAppear:YES];
    
    //should
    [mockMessageManager verify];
    
    //cleanup
    [mockMessageManager stopMocking];
}

@end
