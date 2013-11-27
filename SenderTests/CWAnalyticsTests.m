//
//  CWAnalyticsTests.m
//  Sender
//
//  Created by Khalid on 11/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
//#import <ARAnalytics/ARAnalytics.h>
//#import "ARAnalytics+GoogleAnalytics.h"
//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"

#import "CWAuthenticationManager.h"
#import "CWAnalytics+Spec.h"

@interface CWAuthenticationManager ()
- (void)setAuth:(GTMOAuth2Authentication *)auth;
@end


@interface CWAnalyticsTests : XCTestCase
@end

@implementation CWAnalyticsTests

- (void)setUp
{
    [super setUp];

}

- (void)tearDown
{

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExampleuiubi
{
    [CWAnalytics resetFlag];
    CWAuthenticationManager * authManager = [CWAuthenticationManager sharedInstance];
    
    GTMOAuth2Authentication * auth = [[GTMOAuth2Authentication alloc]init];
    [auth setUserEmail:@"123"];
    [auth setAccessToken:@"auth"];
    [auth setRefreshToken:@"auth"];
    [auth setCode:@"auth"];
    [auth setExpirationDate:[NSDate date]];
    [auth setUserID:@"auth"];
    
    [authManager setAuth:auth];
    
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

@end
