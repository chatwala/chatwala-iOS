//
//  AppDelegateTests.m
//  Sender
//
//  Created by Susan Cudmore on 2/6/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import <OCMock.h>

@interface AppDelegateTests : XCTestCase

@property (nonatomic) AppDelegate* sut;

@end

@implementation AppDelegateTests

- (void)setUp
{
    [super setUp];
    self.sut = [[AppDelegate alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testOpenURL
{
    //given
    NSURL * url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testMessage" withExtension:@"zip"];
    id mockOpener = [OCMockObject mockForClass:[CWOpenerViewController class]];
    self.sut.openerVC = mockOpener;
    [[mockOpener expect] setZipURL:url];

    //when
    [self.sut application:OCMOCK_ANY openURL:url sourceApplication:OCMOCK_ANY annotation:OCMOCK_ANY];

    //should
    [mockOpener verify];

    //cleanup

}

-(void)testNavControllerPushesOpenerVCWhenOpenURLCalled
{
    //given
     NSURL * url = [[NSBundle bundleForClass:[self class]] URLForResource:@"testMessage" withExtension:@"zip"];
    id mockOpener = [OCMockObject mockForClass:[CWOpenerViewController class]];
    [[mockOpener stub] setZipURL:url];
    self.sut.openerVC = mockOpener;


    id mockNavController = [OCMockObject niceMockForClass:[UINavigationController class]];
    self.sut.navController = mockNavController;

    [[mockNavController expect] pushViewController:mockOpener animated:NO];

    //when
    [self.sut application:OCMOCK_ANY openURL:url sourceApplication:OCMOCK_ANY annotation:OCMOCK_ANY];

    //should
    [mockNavController verify];

    //cleanup
    [mockNavController stopMocking];

}
@end
