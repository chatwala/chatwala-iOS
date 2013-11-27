//
//  CWAnalyticsTests.m
//  Sender
//
//  Created by Khalid on 11/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CWAnalytics+Spec.h"
#import "AppDelegate.h"
#import "CWAuthenticationManager.h"
#import "CWAuthRequestViewController.h"
#import "CWErrorViewController.h"
#import "CWSSOpenerViewController.h"
#import "CWReviewViewController.h"
#import "CWSSComposerViewController.h"
#import "CWStartScreenViewController.h"

@interface CWAuthenticationManager ()
- (void)setAuth:(GTMOAuth2Authentication *)auth;
@end

@interface CWAuthRequestViewController ()
- (void)handleBack:(id)sender;
@end

@interface CWOpenerViewController ()<CWVideoPlayerDelegate,CWVideoRecorderDelegate>
- (void)onReviewCountdownTick:(NSTimer*)timer;
@end

@interface CWErrorViewController ()
- (void)onPermissionGranted;
- (void)onPermissionDenied;
@end


@interface CWReviewViewController ()<CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate>
- (void)composeMessageWithData:(NSData*)messageData;
- (NSData*)createMessageData;
@end

@interface CWAnalyticsTests : XCTestCase
@end

@implementation CWAnalyticsTests

- (void)setUp
{
    [super setUp];
    [CWAnalytics resetFlag];

}

- (void)tearDown
{

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testShouldSendEventWhenUserAuthenticatesWithGoogle
{
    
    CWAuthenticationManager * authManager = [CWAuthenticationManager sharedInstance];
    
    GTMOAuth2Authentication * auth = [[GTMOAuth2Authentication alloc]init];
    [auth setUserEmail:@"123"];
    [auth setAccessToken:@"auth"];
    [auth setRefreshToken:@"auth"];
    [auth setCode:@"auth"];
    [auth setExpirationDate:[NSDate date]];
    [auth setUserID:@"auth"];
    
    [authManager setAuth:auth];
    
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void)testShouldSendEventWhenApplicationRecievesMessage
{

    AppDelegate * appdel = [[AppDelegate alloc]init];
    [appdel application:OCMOCK_ANY openURL:OCMOCK_ANY sourceApplication:OCMOCK_ANY annotation:OCMOCK_ANY];
    
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void) testShouldSendEventWhenUserSelectsActivateWithGoogleButtonInAuthVC  {
    
    CWAuthRequestViewController * authVC = [[CWAuthRequestViewController alloc]init];
    [authVC onAuthenticate:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void) testShouldSendEventWhenUserSelectsBackButtonInAuthVC {
    
    CWAuthRequestViewController * authVC = [[CWAuthRequestViewController alloc]init];
    [authVC handleBack:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void) testShouldSendEventWhenUserSelectsAuthEithEmailButtonInAuthVC {
    
    CWAuthRequestViewController * authVC = [[CWAuthRequestViewController alloc]init];
    [authVC onUseEmail:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}


- (void) testShouldSendEventWhenReviewCountdownCompletes {
    
    CWOpenerViewController * openrVC = [[CWOpenerViewController alloc]init];
    [openrVC onReviewCountdownTick:OCMOCK_ANY];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void) testShouldSendEventWhenMessagePlaybackCompletes {
    
    CWOpenerViewController * openrVC = [[CWOpenerViewController alloc]init];
    [openrVC videoPlayerPlayToEnd:OCMOCK_ANY];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void) testShouldSendEventWhenMicAccessGranted {
    CWErrorViewController * errorVC = [[CWErrorViewController alloc]init];
    [errorVC onPermissionGranted];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}


- (void) testShouldSendEventWhenMicAccessDenied {
    CWErrorViewController * errorVC = [[CWErrorViewController alloc]init];
    [errorVC onPermissionDenied];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}


- (void)testShouldSendEventWhenRecordAgainIsSelectedWithIncomingMessage
{
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    id mockReviewVC = [OCMockObject partialMockForObject:reviewVC];
    [[mockReviewVC stub]composeMessageWithData:OCMOCK_ANY];
    [[mockReviewVC stub]createMessageData];
    CWMessageItem * msg = [[CWMessageItem alloc] init];
    msg.videoURL = [[NSBundle mainBundle]URLForResource:@"video" withExtension:@"mp4"];
    [reviewVC setIncomingMessageItem:msg];
    
    [reviewVC onRecordAgain:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
    [mockReviewVC stopMocking];
}

- (void)testShouldSendEventWhenRecordAgainIsSelectedWithoutIncomingMessage
{
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    id mockReviewVC = [OCMockObject partialMockForObject:reviewVC];
    [[mockReviewVC stub]composeMessageWithData:OCMOCK_ANY];
    [[mockReviewVC stub]createMessageData];
    
    [reviewVC onRecordAgain:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
    [mockReviewVC stopMocking];
}

- (void)testShouldSendEventWhenSendIsSelectedWithIncomingMessage
{
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    id mockReviewVC = [OCMockObject partialMockForObject:reviewVC];
    [[mockReviewVC stub]composeMessageWithData:OCMOCK_ANY];
    [[mockReviewVC stub]createMessageData];
    CWMessageItem * msg = [[CWMessageItem alloc] init];
    msg.videoURL = [[NSBundle mainBundle]URLForResource:@"video" withExtension:@"mp4"];
    [reviewVC setIncomingMessageItem:msg];
    
    [reviewVC onSend:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
    [mockReviewVC stopMocking];
}

- (void)testShouldSendEventWhenSendIsSelectedWithoutIncomingMessage
{
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    id mockReviewVC = [OCMockObject partialMockForObject:reviewVC];
    [[mockReviewVC stub]composeMessageWithData:OCMOCK_ANY];
    [[mockReviewVC stub]createMessageData];
    
    [reviewVC onSend:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
    [mockReviewVC stopMocking];
}

- (void)testShouldSendEventWhenMessageIsSent
{
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    [reviewVC mailComposeController:[[MFMailComposeViewController alloc] init] didFinishWithResult:MFMailComposeResultSent error:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}


- (void)testShouldSendEventWhenMessageIsCancelled
{
    CWReviewViewController * reviewVC = [[CWReviewViewController alloc]init];
    [reviewVC mailComposeController:[[MFMailComposeViewController alloc] init] didFinishWithResult:MFMailComposeResultCancelled error:nil];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void)testShouldSendEventWhenScreenTappedOnComposerScreen
{
    CWSSComposerViewController * composeVC = [[CWSSComposerViewController alloc]init];
    [composeVC touchesEnded:[NSSet set] withEvent:OCMOCK_ANY];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
    
}


- (void)testShouldSendEventWhenScreenTappedOnOpenerScreen
{
    CWSSOpenerViewController * openerVC = [[CWSSOpenerViewController alloc]init];
    [openerVC touchesEnded:[NSSet set] withEvent:OCMOCK_ANY];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void)testShouldSendEventWhenOpenerStateIsSetToReview
{
    CWSSOpenerViewController * openerVC = [[CWSSOpenerViewController alloc]init];
    [openerVC setOpenerState:CWOpenerReview];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void)testShouldSendEventWhenOpenerStateIsSetToReact
{
    CWSSOpenerViewController * openerVC = [[CWSSOpenerViewController alloc]init];
    [openerVC setOpenerState:CWOpenerReact];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void)testShouldSendEventWhenOpenerStateIsSetToRespond
{
    CWSSOpenerViewController * openerVC = [[CWSSOpenerViewController alloc]init];
    [openerVC setOpenerState:CWOpenerRespond];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

- (void)testShouldSendEventWhenScreenTappedOnStartScreen
{
    CWStartScreenViewController * startVC = [[CWStartScreenViewController alloc]init];
    [startVC touchesEnded:[NSSet set] withEvent:OCMOCK_ANY];
    XCTAssertTrue([CWAnalytics flagValue], @"should be true");
}

@end
