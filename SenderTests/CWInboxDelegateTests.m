//
//  CWInboxDelegateTests.m
//  Sender
//
//  Created by Susan Cudmore on 2/6/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "AppDelegate.h"
#import "CWInboxViewController.h"
#import "CWMessageManager.h"

@interface AppDelegate (test) <CWInboxDelegate>

@end

@interface CWInboxDelegateTests : XCTestCase

@property (nonatomic) AppDelegate* sut;

@end

@implementation CWInboxDelegateTests

-(void)setUp
{
    [super setUp];
    self.sut = [[AppDelegate alloc] init];
}

-(void)tearDown
{
    [super tearDown];

}

-(void)testInboxViewControllerDidSelectMessageWithIDShouldDownloadMesageWithID
{
    //given
    id mockMessageManager = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[mockMessageManager expect] downloadMessageWithID:@"testID" progress:OCMOCK_ANY completion:OCMOCK_ANY];

    //when
    [self.sut inboxViewController:OCMOCK_ANY didSelectMessageWithID:@"testID"];

    //should
    [mockMessageManager verify];

    //cleanup
    [mockMessageManager stopMocking];
}

@end
