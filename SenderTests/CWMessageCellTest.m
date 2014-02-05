//
//  CWMessageCellTest.m
//  Sender
//
//  Created by randall chatwala on 1/2/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWMessageCell.h"
#import "Message.h"
#import "MocForTests.h"
#import "CWConstants.h"

const NSInteger kSecondsPerMinute = 60;
const NSInteger kSecondsPerHour = 60 * kSecondsPerMinute;
const NSInteger kSecondsPerDay = 24 * kSecondsPerHour;
const NSInteger kSecondsPerWeek = 7 * kSecondsPerDay;
const NSInteger kSecondsPerYear = 52 * kSecondsPerWeek;

@interface CWMessageCellTest : XCTestCase
@property (nonatomic, strong) CWMessageCell * sut;
@property (nonatomic, strong) NSManagedObjectContext * moc;

@end

@implementation CWMessageCellTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.moc = mocFactory.moc;
   
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
    Message * item = [Message insertInManagedObjectContext:self.moc];
    item.thumbnailPictureURL = @"foo";
    
    //when
    [self.sut setMessage:item];
    
    //should
    XCTAssertTrue((self.sut.thumbView.image != nil), @"image should not be nil");
}

- (void)testSetMessageData
{
    //given
    Message * item = [Message insertInManagedObjectContext:self.moc];
    item.thumbnailPictureURL = @"http://chatwala-prod.azurewebsites.net/images/message_thumb.png";
    
    //when
    [self.sut setMessage:item];
    
    //should
    XCTAssertTrue((self.sut.thumbView.image != nil), @"image should not be nil");
}


- (void)testSuccessImageDownloadBlockShouldStopSpinner
{
    //given
    id mockSpinner = [OCMockObject partialMockForObject:self.sut.spinner];
    [[mockSpinner expect] stopAnimating];
    AFNetworkingSuccessBlock block = self.sut.successImageDownloadBlock;
    
    //when
    block(nil, nil, nil);
    
    //should
    [mockSpinner verify];
    
    //cleanup
    [mockSpinner stopMocking];
}


- (void)testSuccessImageDownloadBlockShouldSetImage
{
    //given
    id mockImage = [OCMockObject mockForClass:[UIImage class]];
    id mockThumbView = [OCMockObject partialMockForObject:self.sut.thumbView];
    [[mockThumbView expect] setImage:mockImage];
    AFNetworkingSuccessBlock block = self.sut.successImageDownloadBlock;
    
    //when
    block(nil, nil, mockImage);
    
    //should
    [mockThumbView verify];
    
    //cleanup
    [mockThumbView stopMocking];
}


- (void)testFailureImageDownloadBlockShouldStopSpinner
{
    //given
    id mockSpinner = [OCMockObject partialMockForObject:self.sut.spinner];
    [[mockSpinner expect] stopAnimating];
    AFNetworkingFailureBlock block = self.sut.failureImageDownloadBlock;
    
    //when
    block(nil,nil, nil);
    
    //should
    [mockSpinner verify];
    
    //cleanup
    [mockSpinner stopMocking];
}

- (void)testTimeStringFromDateWithSeconds
{
    //given
    NSInteger wholeSeconds = arc4random_uniform(59) + 1;
    NSTimeInterval time = wholeSeconds;
    NSString * expected = [NSString stringWithFormat:@"%is",wholeSeconds];
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:-time ];
    
    //when
    NSString * actual = [self.sut timeStringFromDate:timeStamp];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"should be the same");
}

- (void)testTimeStringFromDateWithMinutes
{
    //given
    NSInteger wholeMinutes = arc4random_uniform(59) + 1;
    NSTimeInterval time = wholeMinutes * kSecondsPerMinute;
    NSString * expected = [NSString stringWithFormat:@"%im", wholeMinutes];
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:-time ];
    
    //when
    NSString * actual = [self.sut timeStringFromDate:timeStamp];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"should be the same");
}

- (void)testTimeStringFromDateWithHours
{
    //given
    NSInteger wholeHours = arc4random_uniform(23) + 1;
    NSTimeInterval time = wholeHours * kSecondsPerHour;
    NSString * expected = [NSString stringWithFormat:@"%ih", wholeHours];
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:-time ];
    
    //when
    NSString * actual = [self.sut timeStringFromDate:timeStamp];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"should be the same");
}

- (void)testTimeStringFromDateWithDays
{
    //given
    NSInteger wholeDays = arc4random_uniform(6) + 1;
    NSTimeInterval time = wholeDays * kSecondsPerDay;
    NSString * expected = [NSString stringWithFormat:@"%id", wholeDays];
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:-time ];
    
    //when
    NSString * actual = [self.sut timeStringFromDate:timeStamp];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"should be the same");
}


- (void)testTimeStringFromDateWithWeeks
{
    //given
    NSInteger wholeWeeks = arc4random_uniform(51) + 1;
    NSTimeInterval time = wholeWeeks * kSecondsPerWeek;
    NSString * expected = [NSString stringWithFormat:@"%iw", wholeWeeks];
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:-time ];
    
    id mockConstants = [OCMockObject mockForClass:[CWConstants class]];
    [[[mockConstants stub] andReturn:[NSDate distantPast]] launchDate];
    
    //when
    NSString * actual = [self.sut timeStringFromDate:timeStamp];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"should be the same");
    
    //cleanup
    [mockConstants stopMocking];
}

- (void)testTimeStringFromDateWithYears
{
    //given
    NSInteger wholeYears = arc4random_uniform(3) + 1;
    NSTimeInterval time = wholeYears * kSecondsPerYear;
    NSString * expected = [NSString stringWithFormat:@"%iy", wholeYears];
    NSDate * timeStamp = [NSDate dateWithTimeIntervalSinceNow:-time ];
    id mockConstants = [OCMockObject mockForClass:[CWConstants class]];
    [[[mockConstants stub] andReturn:[NSDate distantPast]] launchDate];
    
    //when
    NSString * actual = [self.sut timeStringFromDate:timeStamp];
    
    //should
    XCTAssertEqualObjects(actual, expected, @"should be the same");
    
    //cleanup
    [mockConstants stopMocking];
}

@end
