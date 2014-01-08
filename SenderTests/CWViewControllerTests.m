//
//  CWViewControllerTests.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWViewController.h"
#import "AppDelegate.h"

@interface CWViewControllerTests : XCTestCase

@property (nonatomic) CWViewController * sut;

@end

@implementation CWViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWViewController alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testOnTapShouldToggleDrawer
{
    //given
    AppDelegate * appDel = (AppDelegate *)APPDEL;
    id mockDrawerController = [OCMockObject partialMockForObject:appDel.drawController];
    [[mockDrawerController expect] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:OCMOCK_ANY];
    self.sut.burgerButton = [OCMockObject mockForClass:[UIButton class]];
    
    //when
    [self.sut onTap:self.sut.burgerButton];
    
    //should
    [mockDrawerController verify];
    
    //cleanup
    [mockDrawerController stopMocking];
}

@end
