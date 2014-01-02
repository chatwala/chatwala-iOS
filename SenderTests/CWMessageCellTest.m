//
//  CWMessageCellTest.m
//  Sender
//
//  Created by randall chatwala on 1/2/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWMessageCell.h"

@interface CWMessageCellTest : XCTestCase
@property (nonatomic, strong) CWMessageCell * sut;
@end

@implementation CWMessageCellTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.sut = [[CWMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseID"];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSetMessageDataWithBadData
{
    //given
    NSDictionary * data = @{};
    
    //when
    [self.sut setMessageData:data];
    
    //should
    XCTAssertTrue((self.sut.thumbView.image != nil), @"image should not be nil");
}

- (void)testSetMessageData
{
    //given
    NSDictionary * data = @{@"thumbnail": @"http://chatwala-prod.azurewebsites.net/images/message_thumb.png"};
    
    //when
    [self.sut setMessageData:data];
    
    //should
    XCTAssertTrue((self.sut.thumbView.image != nil), @"image should not be nil");
}

@end
