//
//  CWReviewVCTests.m
//  Sender
//
//  Created by Khalid on 11/13/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <MessageUI/MessageUI.h>
#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWMessageItem.h"
#import "User.h"
#import "CWUserManager.h"



@interface CWReviewViewController ()<CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
- (void)composeMessageWithData:(NSData*)messageData;
- (NSData*)createMessageData;
- (CWMessageItem*)createMessageItemWithSender:(User*) localUser;

@end

@interface CWReviewVCTests : XCTestCase
@property (nonatomic,strong) CWReviewViewController * sut;
@property (nonatomic,strong) id mockSUT;
@property (nonatomic,strong) id mockRecorder;
@property (nonatomic,strong) id mockPlayer;
@property (nonatomic,strong) id mockUser;
@property (nonatomic,strong) CWMessageItem *messageItem;
@end

@implementation CWReviewVCTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    self.sut = [[CWReviewViewController alloc]init];
    [self.sut view];
    self.mockSUT = [OCMockObject partialMockForObject:self.sut];
    self.mockPlayer = [OCMockObject partialMockForObject:self.sut.player];
    self.mockRecorder = [OCMockObject partialMockForObject:self.sut.recorder];
    self.messageItem = [[CWMessageItem alloc] initWithSender:self.mockUser];
    self.mockUser = [OCMockObject niceMockForClass:[User class]];
    NSURL * videoURL = [[NSBundle mainBundle]URLForResource:@"video" withExtension:@"mp4"];
    [self.messageItem setVideoURL:videoURL];
}

- (void)tearDown
{
    [self.mockSUT stopMocking];
    [self.mockPlayer stopMocking];
    [self.mockRecorder stopMocking];
    
    self.sut = nil;
    self.mockSUT = nil;
    self.mockPlayer = nil;
    self.mockRecorder = nil;
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExists
{
    XCTAssertNotNil(self.sut, @"should exist");
}

- (void)testHasPreviewView
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(previewView)];
    XCTAssertTrue(isTrue, @"should have preview view");
}


- (void)testHasSendButton
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(sendButton)];
    XCTAssertTrue(isTrue, @"should have send button");
}


- (void)testRespondsToOnRecordAgain
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(onRecordAgain:)];
    XCTAssertTrue(isTrue, @"should respond to onRecordAgain:");
}

- (void)testRespondsToOnSend
{
    BOOL isTrue = [self.sut respondsToSelector:@selector(onSend:)];
    XCTAssertTrue(isTrue, @"should respond to onSend:");
}

- (void)testPlayerDelegateShouldSetWhenViewWillAppear
{
    [[self.mockPlayer expect]setDelegate:self.sut];
    [self.sut viewWillAppear:NO];
    [self.mockPlayer verify];
}


- (void)testPlayerVideoUrlIsSetWhenViewAppears
{
    [[self.mockPlayer expect]setVideoURL:OCMOCK_ANY];
    [self.sut viewDidAppear:NO];
    [self.mockPlayer verify];
}


- (void)testShouldPlayVideoWhenItLoads
{
    [[self.mockPlayer expect]playVideo];
    [self.sut videoPlayerDidLoadVideo:self.sut.player];
    [self.mockPlayer verify];
}


- (void)testShouldReplayVideoWhenItFinishes
{
    [[self.mockPlayer expect]replayVideo];
}

- (void)testShouldStopVideoPlaybackWhenRecordAgainIsInvoked
{
    [[self.mockPlayer expect]stop];
    [self.sut onRecordAgain:nil];
    [self.mockPlayer verify];
}

- (void)testShouldRemoveVideoPlaybackViewWhenRecordAgainIsInvoked
{
    id playbackView = [OCMockObject partialMockForObject:self.sut.player.playbackView];
    [[playbackView expect]removeFromSuperview];
    [self.sut onRecordAgain:nil];
    [playbackView verify];
    [playbackView stopMocking];
}

- (void)testShouldSetVideoPlaybackViewDelegateToNilWhenRecordAgainIsInvoked
{
    [[self.mockPlayer expect]setDelegate:nil];
    [self.sut onRecordAgain:nil];
    [self.mockPlayer verify];
}


- (void)testShouldPopViewControllerWhenRecordAgainIsInvoked
{
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]popViewControllerAnimated:NO];
    self.sut.incomingMessageItem = OCMOCK_ANY;
    
    [self.sut onRecordAgain:nil];
    [mockNavController verify];
    [mockNavController stopMocking];
}


- (void)testShouldPopViewControllerWhenRecordAgainIsInvokedWhenThereIsNoIncomingMessage
{
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]popToRootViewControllerAnimated:NO];
    self.sut.incomingMessageItem = nil;
    
    [self.sut onRecordAgain:nil];
    [mockNavController verify];
    [mockNavController stopMocking];
}


- (void)testShouldConformToMFMailComposeViewControllerDelegateProtocol
{
    XCTAssertTrue([self.sut conformsToProtocol:@protocol(MFMailComposeViewControllerDelegate) ], @"should conform to main compose vc delegate");
}

- (void)testShouldInvokeComposeMessageWithDataWhenOnSendIsInvoked {
    //given
    CWMessageItem * msg = [[CWMessageItem alloc] initWithSender:self.mockUser];
    msg.videoURL = [[NSBundle mainBundle]URLForResource:@"video" withExtension:@"mp4"];
    id mockUserManager = [OCMockObject partialMockForObject:[CWUserManager sharedInstance]];
    [[mockUserManager expect] localUser:OCMOCK_ANY];
    
    [[[self.mockSUT expect] andReturn:msg] createMessageItemWithSender:self.mockUser];
    
    //when
    [self.sut onSend:nil];
    
    //should
    [mockUserManager verify];
    
}



- (void) testShouldStopPlayerWhenOnSendIsInvoked {
    [[[self.mockSUT stub]andReturn:self.messageItem]createMessageItemWithSender:self.mockUser];
    [[self.mockPlayer expect]stop];
    [self.sut onSend:nil];
    [self.mockPlayer verify];
}

- (void)testShouldPopToRootWhenMailSent
{
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.sut];
    id mockNavController = [OCMockObject partialMockForObject:navController];
    [[mockNavController expect]popToRootViewControllerAnimated:YES];
    
    [self.sut mailComposeController:[[MFMailComposeViewController alloc] init]didFinishWithResult:MFMailComposeResultSent error:nil];
    [mockNavController verify];
    [mockNavController stopMocking];
}


- (void)testShouldreplayVideoWhenMainNotSent
{
    [[self.mockPlayer expect]replayVideo];
    [self.sut mailComposeController:[[MFMailComposeViewController alloc] init]didFinishWithResult:5 error:nil];
    [self.mockPlayer verify];
}

//- (void)testShouldPresentMainComposeVCWhenOnSendIsInvoked
//{
//    [[[self.mockSUT stub]andReturn:self.messageItem]createMessageItem];
//    [[self.mockSUT expect]presentViewController:[OCMArg isNotNil] animated:YES completion:nil];
//    [self.sut onSend:nil];
//    [self.mockSUT verify];
//}

- (void)testShouldProperlySetupMessageItemVideoURLWhenCreateMessageItemIsInvoked
{
    NSURL  * expected = [NSURL URLWithString:@"blah"];
    [self.sut.recorder setOutputFileURL:expected];
    [self.sut createMessageItemWithSender:self.mockUser];
    NSURL * actual = [[self.sut createMessageItemWithSender:self.mockUser]videoURL];
    XCTAssertEqualObjects(expected, actual, @"urls should match");
}
- (void)testShouldProperlySetupMessageItemMetatDataWhenCreateMessageItemIsInvoked
{
    [self.sut setStartRecordingTime:5];
  
    CWMessageItem * msgItem = [self.sut createMessageItemWithSender:self.mockUser];
    XCTAssertTrue( msgItem.metadata.startRecording == 5, @"recording start time should match");
}


@end
