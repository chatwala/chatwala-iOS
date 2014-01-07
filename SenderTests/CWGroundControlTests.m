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
#import "AppDelegate.h"

@interface CWGroundControlTests : XCTestCase

@property (nonatomic) id mockSut;
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
    self.mockSut = [OCMockObject partialMockForObject:self.sut];
}

- (void)tearDown
{
    [self.mockSut stopMocking];
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

- (void) testRefreshSuccesShouldShowKillScreen
{
    //given
    NSDictionary * someDictionary = OCMOCK_ANY;
    [[[self.mockSut stub] andReturnValue:@YES] shouldShowKillScreen];
    [[self.mockSut expect] showKillScreen];
    
    //when
    self.sut.refreshSuccessBlock(someDictionary);
    
    //should
    [self.mockSut verify];
}

- (void) testRefreshSuccesShouldNotShowKillScreen
{
    //given
    NSDictionary * someDictionary = OCMOCK_ANY;
    [[[self.mockSut stub] andReturnValue:@NO] shouldShowKillScreen];
    [[self.mockSut reject] showKillScreen];
    
    //when
    self.sut.refreshSuccessBlock(someDictionary);
    
    //should
    [self.mockSut verify];
}

- (void) testRefreshFailureShouldShowKillScreen
{
    //given
    [[[self.mockSut stub] andReturnValue:@YES] shouldShowKillScreen];
    [[self.mockSut expect] showKillScreen];
    
    //when
    self.sut.refreshFailureBlock(OCMOCK_ANY);
    
    //should
    [self.mockSut verify];
}

- (void) testRefreshFailureShouldNotShowKillScreen
{
    //given
    [[[self.mockSut stub] andReturnValue:@NO] shouldShowKillScreen];
    [[self.mockSut reject] showKillScreen];
    
    //when
    self.sut.refreshFailureBlock(OCMOCK_ANY);
    
    //should
    [self.mockSut verify];
}

- (void) testShowKillScreen
{
    //given
    AppDelegate * appDel = [[UIApplication sharedApplication] delegate];
    id mockNavController = [OCMockObject partialMockForObject:appDel.navController];
    [[mockNavController expect] pushViewController:OCMOCK_ANY animated:NO];
    id mockDrawController = [OCMockObject partialMockForObject:appDel.drawController];
    [[mockDrawController expect] closeDrawerAnimated:NO completion:OCMOCK_ANY];
    
    //when
    [self.sut showKillScreen];
    
//    should
    [mockNavController verify];
    [mockDrawController verify];
    
    //cleanup
    [mockNavController stopMocking];
    [mockDrawController stopMocking];
}

- (void) testShouldShowKillScreenShouldReturnYes
{
    //given
    [[[self.mockUserDefaults stub] andReturnValue:@YES] boolForKey:@"APP_DISABLED"];
    
    //when
    BOOL actual = [self.sut shouldShowKillScreen];
    
    //should
    XCTAssertTrue(actual, @"expecting shouldShowKillScreen to return YES");
}

- (void) testShouldShowKillScreenShouldReturnNO
{
    //given
    [[[self.mockUserDefaults stub] andReturnValue:@NO] boolForKey:@"APP_DISABLED"];
    
    //when
    BOOL actual = [self.sut shouldShowKillScreen];
    
    //should
    XCTAssertFalse(actual, @"expecting shouldShowKillScreen to return YES");
}
@end
