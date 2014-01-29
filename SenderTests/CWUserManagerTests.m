//
//  CWUserManagerTests.m
//  Sender
//
//  Created by randall chatwala on 1/15/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "CWUserManager.h"
#import "CWDataManager.h"
#import "MocForTests.h"


@interface CWUserManager (exposingForTest)
@property (nonatomic) AFHTTPRequestOperation * fetchUserIDOperation;


@end

@interface CWUserManagerTests : XCTestCase

@property (nonatomic) CWUserManager * sut;
@property (nonatomic) NSManagedObjectContext * moc;

@end

@implementation CWUserManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWUserManager alloc] init];
    
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.moc = mocFactory.moc;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testLocalUserShouldCallCompletionWhenWeAlreadyHaveUserID
{
    //given
    __block BOOL callbackRan = NO;
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockUserDefaults stub] andReturn:@"myuserID"] valueForKey:@"CHATWALA_USER_ID"];
    id mockDataManager = [OCMockObject partialMockForObject:[CWDataManager sharedInstance]];
    [[mockDataManager  expect] createUserWithID:@"myuserID"];
    
    //when
    [self.sut localUser:^(User *localUser) {
        callbackRan = YES;
    }];
    
    //should
    XCTAssertTrue(callbackRan, @"callback should have run");
    
    //cleanup
    [mockUserDefaults stopMocking];
    [mockDataManager stopMocking];
}
- (void) testLocalUserShouldNotRequestNewUserIDWhenAlreadyHasUserID
{
    //given
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockUserDefaults stub] andReturn:@"something"] valueForKey:@"CHATWALA_USER_ID"];
    id mockAFOpertaionManager = [OCMockObject mockForClass:[AFHTTPRequestOperationManager class]];
    [[[mockAFOpertaionManager stub] andReturn:mockAFOpertaionManager] manager];
    [[mockAFOpertaionManager reject] GET:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    //when
    [self.sut localUser:nil];
    
    //should
    [mockAFOpertaionManager verify];
    
    
    //cleanup
    [mockUserDefaults stopMocking];
}


- (void) testLocalUserShouldRequestNewUserID
{
    //given
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockUserDefaults stub] andReturn:nil] valueForKey:@"CHATWALA_USER_ID"];
    id mockAFOpertaionManager = [OCMockObject mockForClass:[AFHTTPRequestOperationManager class]];
    [[[mockAFOpertaionManager stub] andReturn:mockAFOpertaionManager] manager];
    [[mockAFOpertaionManager expect] GET:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    [[mockAFOpertaionManager expect] setRequestSerializer:OCMOCK_ANY];
    
    //when
    [self.sut localUser:nil];

    //should
    [mockAFOpertaionManager verify];
    
    
    //cleanup
    [mockUserDefaults stopMocking];
}

- (void) testUserIDCompletionBlock
{
    //given
    NSString * userID = @"my_USER_IDBIEOB";
    User * expected = [User insertInManagedObjectContext:self.moc];
    id mockDataManager = [OCMockObject partialMockForObject:[CWDataManager sharedInstance]];
    [[[mockDataManager expect] andReturn:expected] createUserWithID:userID];
    
    __block User * actual = nil;
    CWUserManagerLocalUserBlock completionBlock = ^(User * user){
        actual = user;
    };
    
    //when
    self.sut.getUserIDCompletionBlock(OCMOCK_ANY, @[@{@"user_id":userID}], completionBlock);
    
    //should
    XCTAssertEqualObjects(actual, expected, @"expecting users to match");
    
    [mockDataManager stopMocking];
}

- (void) testLocalUserRequestShouldCancelOldOperation
{
    //given
    id mockOperation = [OCMockObject niceMockForClass:[AFHTTPRequestOperation class]];
    self.sut.fetchUserIDOperation = mockOperation;
    [[mockOperation expect] cancel];
    
    //flow control
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockUserDefaults stub] andReturn:nil] valueForKey:@"CHATWALA_USER_ID"];
    id mockAFOpertaionManager = [OCMockObject mockForClass:[AFHTTPRequestOperationManager class]];
    [[[mockAFOpertaionManager stub] andReturn:mockAFOpertaionManager] manager];
    [[mockAFOpertaionManager stub] GET:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    [[mockAFOpertaionManager stub] setRequestSerializer:OCMOCK_ANY];
    
    //when
    [self.sut localUser:nil];
    
    //should
    XCTAssertNotEqual(self.sut.fetchUserIDOperation, mockOperation, @"expecting operation to be reset");
    [mockOperation verify];
    
    //cleanup
    [mockAFOpertaionManager stopMocking];
    [mockUserDefaults stopMocking];
}

- (void)testRequestAppFeedbackReturnsAppVersion
{
    //given
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[mockUserDefaults expect] setObject:OCMOCK_ANY forKey:kAppVersionWhenFeedbackRequestedKey];
    
    //when
    [self.sut didRequestAppFeedback];
    
    //should
    [mockUserDefaults verify];
    
    //cleanup
    [mockUserDefaults stopMocking];
    
}

- (void)testAppFeedbackHasBeenRequestedReturnsVersionString
{
    
    //given
    NSString * expected = @"Somewin3intbtibgd";
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[mockUserDefaults stub] andReturn:expected] stringForKey:kAppVersionWhenFeedbackRequestedKey];
    
    //when
    NSString* actual = [self.sut appFeedbackHasBeenRequested];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"expecting version to be the one found in NSUserDefaults");
    
    //cleanup
    [mockUserDefaults stopMocking];
}
@end
