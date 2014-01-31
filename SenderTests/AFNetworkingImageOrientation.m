//
//  AFNetworkingImageOrientation.m
//  Sender
//
//  Created by randall chatwala on 1/31/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AFNetworking.h>
#import <AFNetworking/AFURLResponseSerialization.h>
#import <OCMock.h>


@interface AFNetworkingImageOrientation : XCTestCase

@property (nonatomic) AFImageResponseSerializer * sut;
@property (nonatomic) id mockSUT;

@end

@implementation AFNetworkingImageOrientation

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[AFImageResponseSerializer alloc] init];
    self.mockSUT = [OCMockObject partialMockForObject:self.sut];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [self.mockSUT stopMocking];
    [super tearDown];
}

- (void)testOrientationIsCorrect
{
    //given
    UIImage * sourceImage = [UIImage imageNamed:@"default"];
    UIImage * rotatedImage = [UIImage imageWithCGImage:sourceImage.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    NSData * imageData = UIImageJPEGRepresentation(rotatedImage, 1.0);

    id mockResponse = [OCMockObject niceMockForClass:[NSHTTPURLResponse class]];
    [[[self.mockSUT stub] andReturnValue:@YES] validateResponse:OCMOCK_ANY data:OCMOCK_ANY error:nil];
    
    //when
    UIImage * actual = [self.sut responseObjectForResponse:mockResponse data:imageData error:nil];
    
    //should
    XCTAssertEqual(actual.imageOrientation, rotatedImage.imageOrientation, @"expecting image orientation to be passed");
    
}

@end
