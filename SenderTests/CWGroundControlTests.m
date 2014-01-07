//
//  CWGroundControlTests.m
//  Sender
//
//  Created by randall chatwala on 1/7/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWGroundControlManager.h"
#import <OCMock/OCMock.h>

@interface CWGroundControlTests : XCTestCase

@property (nonatomic) id mockUserDefaults;
@property (nonatomic) CWGroundControlManager * sut;
@end

@implementation CWGroundControlTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    
    self.sut = [[CWGroundControlManager alloc] init];
    
}

- (void)tearDown
{
    [self.mockUserDefaults stopMocking];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testRefreshShouldGrabNewSettings
{
    //given
    [[self.mockUserDefaults expect] registerDefaultsWithURL:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    [self.sut refresh];
    
    //should
    [self.mockUserDefaults verify];
}

@end
