//
//  CWMenuViewControllerTests.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "CWInboxViewController.h"
#import "CWMessageManager.h"
#import "User.h"
#import "MocForTests.h"
#import "CWUserManager.h"

@interface CWInboxViewController (test) <UITableViewDelegate>

@end

@interface CWInboxViewControllerTestDelegate : NSObject <CWInboxDelegate>

@end

@implementation CWInboxViewControllerTestDelegate
- (void)inboxViewController:(CWInboxViewController*)inboxVC didSelectButton:(UIButton*)button
{

}
- (void)inboxViewController:(CWInboxViewController*)inboxVC didSelectMessageWithID:(NSString*)messageId
{

}

@end

@interface CWInboxViewControllerTests : XCTestCase

@property (nonatomic) CWInboxViewController * sut;
@property (nonatomic) NSManagedObjectContext* moc;

@end

@implementation CWInboxViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWInboxViewController alloc] init];
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.moc = mocFactory.moc;

}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testViewDidLoadShouldGetNewMessages
{
    //given
    id mockMessageManager = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[mockMessageManager expect] getMessagesForUser:OCMOCK_ANY withCompletionOrNil:OCMOCK_ANY];
    
    //when
    [self.sut viewDidAppear:YES];
    
    //should
    [mockMessageManager verify];
    
    //cleanup
    [mockMessageManager stopMocking];
}

-(void)testTableViewDidSelectRowCallsDelegateDidSelectMessageWithID
{
    //given
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];

    User* testUser = [User insertInManagedObjectContext:self.moc];
    id userManager = [OCMockObject partialMockForObject:[CWUserManager sharedInstance]];
    [[[userManager stub] andReturn:testUser] localUser];

    Message* msg1 = [Message insertInManagedObjectContext:self.moc];
    Message* msg2 = [Message insertInManagedObjectContext:self.moc];
    msg2.messageID = @"testMsgId";


    NSOrderedSet* messages = [NSOrderedSet orderedSetWithObjects:msg1, msg2, nil];

    id mockLocalUser = [OCMockObject partialMockForObject:testUser];
    [[[mockLocalUser stub] andReturn:messages] inboxMessages];

    CWInboxViewControllerTestDelegate * testDelegate =[[CWInboxViewControllerTestDelegate alloc] init];
    self.sut.delegate = testDelegate;
    id mockTestDelegate = [OCMockObject partialMockForObject:testDelegate];
    [[mockTestDelegate expect] inboxViewController:self.sut didSelectMessageWithID:msg2.messageID];

    //when
    [self.sut tableView:OCMOCK_ANY didSelectRowAtIndexPath:indexPath];

    //should
    [mockTestDelegate verify];

    //cleanup
    [userManager stopMocking];
    [mockLocalUser stopMocking];
    [mockTestDelegate stopMocking];
}


//- (void)testThatDelegateOpensCorrectMessageWhenSelected
//{
//    //given
//    id mockMessageManager = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
//    [[mockMessageManager expect] getMessagesForUser:OCMOCK_ANY withCompletionOrNil:OCMOCK_ANY];
//
//    //when
//    [self.sut.messagesTable.delegate tableView];
//
//    //should
//    [mockMessageManager verify];
//
//    //cleanup
//    [mockMessageManager stopMocking];
//
//}

@end
