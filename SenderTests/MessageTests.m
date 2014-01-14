//
//  MessageTests.m
//  Sender
//
//  Created by randall chatwala on 1/13/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Message.h"
#import "MocForTests.h"
#import "Message.h"
#import "CWMessageCell.h"
#import "CWMessageManager.h"

@interface MessageTests : XCTestCase

@property (nonatomic) Message * sut;

@end

@implementation MessageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    MocForTests * mocFactory = [[MocForTests alloc] initWithPath:@"ChatwalaModel"];
    self.sut = [Message insertInManagedObjectContext:mocFactory.moc];
    
    self.sut.messageID = @"Some message ID";

}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDownloadChatwalaDataShouldStartThumbnailDownload
{
    //given
    self.sut.thumbnailPictureURL = @"http://chatwala-prod.azurewebsites.net/images/message_thumb.png";
    CWMessageCell * messageCell = [[CWMessageCell alloc] init];
    id mockImageView = [OCMockObject mockForClass:[UIImageView class]];
    [[mockImageView expect] setImageWithURLRequest:OCMOCK_ANY placeholderImage:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    messageCell.thumbView = mockImageView;
    id messageManagerMock = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[messageManagerMock stub] downloadMessageWithID:@"Some message ID" progress:nil completion:nil];

    //when
    [self.sut downloadChatwalaDataWithMessageCell:messageCell];
    
    //should
    [mockImageView verify];
    
    //cleanup
    [mockImageView stopMocking];
    [messageManagerMock stopMocking];
    
}

- (void)testDownloadChatwalaDataShouldStartMessageDownload
{
    //given
    id messageManagerMock = [OCMockObject partialMockForObject:[CWMessageManager sharedInstance]];
    [[messageManagerMock expect] downloadMessageWithID:@"Some message ID" progress:nil completion:nil];
    //when
    [self.sut downloadChatwalaDataWithMessageCell:nil];
    
    //should
    [messageManagerMock verify];
    
    //cleanup
    [messageManagerMock stopMocking];
    
}


@end
