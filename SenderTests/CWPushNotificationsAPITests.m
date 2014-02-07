//
//  CWPushNotificationsAPITests.m
//  Sender
//
//  Created by Susan Cudmore on 2/7/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CWPushNotificationsAPI.h"
#import "AppDelegate.h"

@interface CWPushNotificationsAPITests : XCTestCase

@end

@implementation CWPushNotificationsAPITests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testRegisterForPushNotificationsCallsRegisterForRemoteNotificationTypes
{
    //given
    id mockUIApplication = [OCMockObject partialMockForObject:[UIApplication sharedApplication]];
    [[mockUIApplication expect] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge];

    //when
    [CWPushNotificationsAPI registerForPushNotifications];

    //should
    [mockUIApplication verify];

    //cleanup
    [mockUIApplication stopMocking];
}


@end
