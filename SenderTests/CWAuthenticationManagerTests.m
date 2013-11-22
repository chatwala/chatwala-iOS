//
//  CWAuthenticationManagerTests.m
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWAuthenticationManager.h"

@interface CWAuthenticationManagerTests : XCTestCase
@property (nonatomic,strong) CWAuthenticationManager * sut;
@property (nonatomic,strong) id mockSUT;
@end


@interface CWAuthenticationManager ()
@property (nonatomic,assign) BOOL skippedAuth;
@end


@implementation CWAuthenticationManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWAuthenticationManager alloc]init];
    self.mockSUT = [OCMockObject partialMockForObject:self.sut];
}

- (void)tearDown
{
    [self.mockSUT stopMocking];
    self.mockSUT = nil;
    self.sut = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testShouldShowAuthReturnYesAllFlagsAreFalse
{

    [[[self.mockSUT stub]andReturnValue:@NO]isFirstRun];
    [[[self.mockSUT stub]andReturnValue:@NO]skippedAuth];
    [[[self.mockSUT stub]andReturnValue:@NO]isAuthenticated];
    
    XCTAssertTrue([self.sut shouldShowAuth], @"should be YES");
}




- (void)testShouldReturnNoForFirstRunAfterFinishedFirstRunIsInvoked
{
    [self.sut didFinishFirstRun];
    XCTAssertFalse([self.sut isFirstRun], @"should be YES");
}

- (void)testShouldShowAuthReturnsNoWhenAuthSkipped
{
    [self.sut didSkipAuth];
    XCTAssertFalse([self.sut shouldShowAuth], @"should be NO");
}


- (void)testShouldShowAuthReturnsNoWhenAuthenticated
{
    [[[self.mockSUT stub]andReturnValue:@YES]isAuthenticated];
    
    XCTAssertFalse([self.sut shouldShowAuth], @"should be NO");
}


@end
