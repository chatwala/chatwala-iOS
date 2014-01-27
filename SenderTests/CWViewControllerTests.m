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
#import "UIViewController+MMDrawerController.h"

@interface CWViewControllerTests : XCTestCase

@property (nonatomic) CWViewController * sut;
@property (nonatomic) id mockSut;

@end

@implementation CWViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWViewController alloc] init];
    self.mockSut = [OCMockObject partialMockForObject:self.sut];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [self.mockSut stopMocking];
    [super tearDown];
}

- (void)testOnTapShouldToggleDrawer
{
    //given
    id mockDrawerController = [OCMockObject mockForClass:[MMDrawerController class]];
    [[mockDrawerController expect] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:OCMOCK_ANY];
    [[[self.mockSut stub] andReturn:mockDrawerController] mm_drawerController];
    self.sut.burgerButton = [OCMockObject mockForClass:[UIButton class]];
    [[self.mockSut expect] rotateBurgerBarAfterDrawAnimation:NO];
    
    //when
    [self.sut onTap:self.sut.burgerButton];
    
    //should
    [mockDrawerController verify];
    [self.mockSut verify];
    
    //cleanup
    [mockDrawerController stopMocking];
}

@end
