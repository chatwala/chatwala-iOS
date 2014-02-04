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
#import "User.h"
#import "Message.h"
#import "CWGroundControlManager.h"

@interface CWUserManager (exposingForTest)
@property (nonatomic) AFHTTPRequestOperation * fetchUserIDOperation;
@property (nonatomic) User * localUser;


@end

@interface CWUserManagerTests : XCTestCase

@property (nonatomic) CWUserManager * sut;
@property (nonatomic) NSManagedObjectContext * moc;
@property (nonatomic) id mockSut;
@property (nonatomic) id mockUserDefaults;

@end

@implementation CWUserManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    self.mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[[self.mockUserDefaults stub] andReturn:@"myuserID"] valueForKey:@"CHATWALA_USER_ID"];

    self.sut = [[CWUserManager alloc] init];
    
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.moc = mocFactory.moc;
    
    self.mockSut = [OCMockObject partialMockForObject:self.sut];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [self.mockSut stopMocking];
    [self.mockUserDefaults stopMocking];
    [super tearDown];
}

- (void)testLocalUserShouldUseIDInUserDefaults
{
    //given
    
    //when
    User * actual = [self.sut localUser];
    
    //should
    XCTAssertEqualObjects(actual.userID, @"myuserID", @"expecting same user ID");
    
    //cleanup
}

- (void) testLocalUserShouldRequestNewUserID
{
    //given
    User *expected = [User insertInManagedObjectContext:self.moc];
    id mockDataManager = [OCMockObject partialMockForObject:[CWDataManager sharedInstance]];
    [[[mockDataManager expect] andReturn:expected] createUserWithID:@"myuserID"];
    [[[self.mockUserDefaults stub] andReturn:nil] valueForKey:@"CHATWALA_USER_ID"];
    
    //when
    User *actual = [self.sut localUser];

    //should
    XCTAssertEqualObjects(actual, expected, @"user should be new");
    [mockDataManager verify];
    
    //cleanup
    [mockDataManager stopMocking];
}

- (void)testRequestAppFeedbackReturnsAppVersion
{
    //given
    id mockUserDefaults = [OCMockObject partialMockForObject:[NSUserDefaults standardUserDefaults]];
    [[mockUserDefaults expect] setObject:OCMOCK_ANY forKey:kAppVersionOfFeedbackRequestedKey];
    
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
    [[[mockUserDefaults stub] andReturn:expected] stringForKey:kAppVersionOfFeedbackRequestedKey];
    
    //when
    NSString* actual = [self.sut appVersionOfAppFeedbackRequest];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"expecting version to be the one found in NSUserDefaults");
    
    //cleanup
    [mockUserDefaults stopMocking];
}

- (void) testShouldRequestAppFeecbackShouldReturnNOWhenVersionStringExists
{
    //given
   
    [[[self.mockSut stub] andReturn:@"SOMEversionNumber"] appVersionOfAppFeedbackRequest];
    
    //when
    BOOL actual = [self.sut shouldRequestAppFeedback];
    
    //should
    XCTAssertFalse(actual, @"expecting the function to return NO");
    
    //cleanup
}


- (void) testShouldRequestAppFeedbackShouldReturnNOWhenUserHasNotSentMoreThan5Messages
{
    //given
    [[[self.mockSut stub] andReturn:nil] appVersionOfAppFeedbackRequest];
    self.sut.localUser = [User insertInManagedObjectContext:self.moc];
    const NSInteger numberOfSentMessagesThreshold = 15;
    const NSInteger numberOfSentMessages = arc4random_uniform(numberOfSentMessagesThreshold);
    id mockGroundControl = [OCMockObject partialMockForObject:[CWGroundControlManager sharedInstance]];
    [[[mockGroundControl stub] andReturn:@(numberOfSentMessagesThreshold)] appFeedbackSentMessageThreshold];
    for(int ii = 0; ii < numberOfSentMessages; ++ii)
    {
        [self.sut.localUser addMessagesSentObject:[Message insertInManagedObjectContext:[self.sut.localUser managedObjectContext]]];
    }
    
    //when
    BOOL actual = [self.sut shouldRequestAppFeedback];
    
    //should
    XCTAssertFalse(actual, @"expecting the function to return NO");
    
    //cleanup
    [mockGroundControl stopMocking];
}


- (void) testShouldRequestAppFeedbackShouldReturnYESWhenUserHasSentMoreThan5MessagesAndHasNotRequestedFeedback
{
    //given
    [[[self.mockSut stub] andReturn:nil] appVersionOfAppFeedbackRequest];
    self.sut.localUser = [User insertInManagedObjectContext:self.moc];
    const NSInteger numberOfSentMessagesThreshold = 15;
    const NSInteger numberOfSentMessages = numberOfSentMessagesThreshold + arc4random_uniform(5);
    id mockGroundControl = [OCMockObject partialMockForObject:[CWGroundControlManager sharedInstance]];
    [[[mockGroundControl stub] andReturn:@(numberOfSentMessagesThreshold)] appFeedbackSentMessageThreshold];
    for(int ii = 0; ii < numberOfSentMessages; ++ii)
    {
        [self.sut.localUser addMessagesSentObject:[Message insertInManagedObjectContext:[self.sut.localUser managedObjectContext]]];
    }
    
    //when
    BOOL actual = [self.sut shouldRequestAppFeedback];
    
    //should
    XCTAssertTrue(actual, @"expecting the function to return YES when you have %i sent messages and the threshold is %i", numberOfSentMessages, numberOfSentMessagesThreshold);
    
    //cleanup
    [mockGroundControl stopMocking];
}


@end
