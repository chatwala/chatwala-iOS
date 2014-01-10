//
//  CWDataManagerTests.m
//  Sender
//
//  Created by randall chatwala on 1/9/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CWDataManager.h"
#import "MocForTests.h"

@interface CWDataManagerTests : XCTestCase

@property (nonatomic) CWDataManager * sut;

@end

@implementation CWDataManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWDataManager alloc] init];
 
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.sut.moc = mocFactory.moc;

}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testImportMessagesShouldReturnErrorWithBadData
{
    //given
    NSArray * messagesImport = @[@"blah"];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNotNil(error, @"expecting an error");
}

- (void)testImportMessagesShouldReturnErrorWithBadData2
{
    //given
    NSArray * messagesImport = @[@{@"blah":@"foo"}];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNotNil(error, @"expecting an error");
}

- (void) testImportMessagesShouldNotReturnErrorWithValidData
{
    //given
    NSArray * messagesImport = @[@{@"messageID":@"foo", @"messageURL": @"someURL", @"timeStamp": @"2013-09-29T18:46:19"}];
    
    //when
    NSError * error = [self.sut importMessages:messagesImport];
    
    //should
    XCTAssertNil(error, @"not expecting an error");
}

@end
