//
//  CWReviewViewController.m
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWReviewViewController.h"
#import "CWVideoManager.h"
#import "CWAuthenticationManager.h"
#import "CWFlowManager.h"
#import "CWAuthenticationManager.h"
#import "AppDelegate.h"
#import "CWLandingViewController.h"
#import "CWGroundControlManager.h"
#import "CWMessageManager.h"
#import "CWUserManager.h"
#import "CWUtility.h"


@interface CWReviewViewController () <UINavigationControllerDelegate,CWVideoPlayerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    CWVideoPlayer * player;
    CWVideoRecorder * recorder;
    NSInteger playbackCount;
 
}
@property (nonatomic,strong) CWVideoPlayer * player;
@property (nonatomic,strong) CWVideoRecorder * recorder;
@property (nonatomic,strong) MFMailComposeViewController *mailComposer;
@end

@implementation CWReviewViewController

@synthesize player;
@synthesize recorder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    player =[[CWVideoManager sharedManager]player];
    recorder = [[CWVideoManager sharedManager]recorder];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToBackground)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    [self setNavMode:NavModeClose];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    playbackCount = 0;
    [player setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [player setVideoURL:recorder.tempFileURL];
}


- (void)goToBackground
{
    if (self.mailComposer) {
        [[self mailComposer]dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)composeMessageWithMessageKey:(NSString*)messageURL
{    
    // SMS
    MFMessageComposeViewController  * smsComposer = [[MFMessageComposeViewController alloc] init];
    [smsComposer setMessageComposeDelegate:self];
    [smsComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
    [smsComposer setBody:[NSString stringWithFormat:@"Hey, I sent you a video message on Chatwala: %@",messageURL]];
    
    [self presentViewController:smsComposer  animated:YES completion:nil];
    
    /*
    // MAIL
    self.mailComposer = [[MFMailComposeViewController alloc] init];
    [self.mailComposer setMailComposeDelegate:self];
    [self.mailComposer setSubject:[[CWGroundControlManager sharedInstance] emailSubject]];
    
    
    if (self.incomingMessageItem.metadata.senderId) {
        [[self mailComposer] setToRecipients:@[self.incomingMessageItem.metadata.senderId]];
    }
    
//    [[self mailComposer]  setMessageBody:[[CWGroundControlManager sharedInstance] emailMessage] isHTML:YES];
    [[self mailComposer]  setMessageBody:messageURL isHTML:NO];
    
//    [[self mailComposer]  addAttachmentData:messageData mimeType:@"application/octet-stream" fileName:@"chat.wala"];
    [self presentViewController:[self mailComposer]  animated:YES completion:nil];
    
    */
}


- (CWMessageItem*)createMessageItem
{
    CWMessageItem * message = [[CWMessageItem alloc]init];
    [message setVideoURL:recorder.outputFileURL];
    message.metadata.startRecording = self.startRecordingTime;
    
    
    if ([[CWAuthenticationManager sharedInstance]isAuthenticated]) {
        [message.metadata setSenderId:[[CWAuthenticationManager sharedInstance] userEmail]];
    }
    
    if (self.incomingMessageItem) {
        [message.metadata setRecipientId:self.incomingMessageItem.metadata.senderId];
        [message.metadata setThreadId:self.incomingMessageItem.metadata.threadId];
        [message.metadata setThreadIndex:self.incomingMessageItem.metadata.threadIndex+1];
    }
    return message;
}


- (void)onTap:(id)sender
{
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    
    if (self.incomingMessageItem) {
        // responding
        
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
//    [super onTap:sender];
}


- (IBAction)onRecordAgain:(id)sender {
    [player.playbackView removeFromSuperview];
    [player setDelegate:nil];
    [player stop];
    
    if (self.incomingMessageItem) {
        // responding
        
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [CWAnalytics event:@"REDO_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    
    
}

#pragma mark - Message Sending

- (IBAction)onSend:(id)sender {
    
    if (self.sendButton.buttonState == eButtonStateBusy) {
        return;
    }
    
    
    [player stop];

    //    [self composeMessageWithData:[self createMessageData]];
    [self.sendButton setButtonState:eButtonStateBusy];
    
    CWMessageItem * message = [self createMessageItem];
    [message exportZip];
    
    if (self.incomingMessageItem) {
        // Responding to an incoming message
        [CWAnalytics event:@"SEND_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
        
        [[CWMessageManager sharedInstance] fetchMessageIDForReplyToMessage:message completionBlockOrNil:^(NSString *messageID, NSString *messageURL) {
            if (messageID && messageURL) {
                message.metadata.messageId = messageID;
                
                [[CWMessageManager sharedInstance] uploadMesage:message isReply:YES];
                [self.sendButton setButtonState:eButtonStateShare];
                [self didSendMessage];
                [CWAnalytics event:@"SENT_MESSAGE" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:@(playbackCount)];
            }
            else {
                return;
            }
        }];
        
    }else{
        // Original message send
        
        [CWAnalytics event:@"SEND_MESSAGE" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:@(playbackCount)];
        [[CWMessageManager sharedInstance] fetchOriginalMessageIDWithCompletionBlockOrNil:^(NSString *messageID, NSString *messageURL) {
            
            if (messageID && messageURL) {
                message.metadata.messageId = messageID;
                [[CWMessageManager sharedInstance] uploadMesage:message isReply:NO];
                [self composeMessageWithMessageKey:messageURL];
            }
            else {
                return;
            }
        }];
    }
}

- (void) uploadProfilePicture
{
    NSString * const uploadedProfilePicture = @"profilePictureKey";
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:uploadedProfilePicture] boolValue])
    {
        return;//already did this
    }
    
    [self.player createThumbnailWithCompletionHandler:^(UIImage *thumbnail) {
        NSLog(@"thumbnail created:%@", thumbnail);
        
        NSURL * thumbnailURL = [[CWUtility cacheDirectoryURL] URLByAppendingPathComponent:@"thumbnailImage.png"];
        [UIImagePNGRepresentation(thumbnail) writeToURL:thumbnailURL atomically:YES];

        NSString * user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"CHATWALA_USER_ID"];

        NSString * endPoint = [NSString stringWithFormat:[[CWMessageManager sharedInstance] putUserProfileEndPoint] , user_id];
        NSLog(@"uploading profile image: %@",endPoint);
        NSURL *URL = [NSURL URLWithString:endPoint];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:@"PUT"];
        [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
        
        AFURLSessionManager * mgr = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionUploadTask * task = [mgr uploadTaskWithRequest:request fromFile:thumbnailURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            //
            if (error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                NSLog(@"Successfully upload profile picture: %@ %@", response, responseObject);
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:uploadedProfilePicture];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
        
        [task resume];
        
    }];
    
}

- (void) didSendMessage
{
    [self uploadProfilePicture];
//    [NC postNotificationName:@"message_sent" object:nil userInfo:nil];
    
    [[NSUserDefaults standardUserDefaults]setValue:@(YES) forKey:@"MESSAGE_SENT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[CWAuthenticationManager sharedInstance]didSkipAuth];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark CWVideoPlayerDelegate

- (void)videoPlayerDidLoadVideo:(CWVideoPlayer *)videoPlayer
{
    [self showVideoPreview];
}

- (void)showVideoPreview
{
//    [self.view insertSubview:self.player.playbackView belowSubview:self.recordAgainButton];
    [self.previewView addSubview:player.playbackView];
    self.previewView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5);
    player.playbackView.frame = self.previewView.bounds;
    
    
    [player playVideo];
}

- (void)videoPlayerPlayToEnd:(CWVideoPlayer *)videoPlayer
{
    playbackCount++;
    [player replayVideo];
}

- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError *)error
{
    
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self.sendButton setButtonState:eButtonStateShare];
    
    switch (result) {
        case MFMailComposeResultSent:
            {
                if (self.incomingMessageItem) {
                    [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
                }else{
                    [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Message" withLabel:@"" withValue:nil];
                }
                [self didSendMessage];
            }
            break;
    
        case MFMailComposeResultCancelled:
            if (self.incomingMessageItem) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Reply Message" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"Send Message" withLabel:@"" withValue:nil];
            }
            [self.player replayVideo];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.mailComposer= nil;
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.sendButton setButtonState:eButtonStateShare];
    
    switch (result) {
        case MessageComposeResultSent:
        {
            if (self.incomingMessageItem) {
                [CWAnalytics event:@"MESSAGE_SENT" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_SENT" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            
            [self didSendMessage];
        }
            break;
            
        case MessageComposeResultCancelled:
            if (self.incomingMessageItem) {
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_REPLIER" withLabel:@"" withValue:nil];
            }else{
                [CWAnalytics event:@"MESSAGE_CANCELLED" withCategory:@"CONVERSATION_STARTER" withLabel:@"" withValue:nil];
            }
            [self.player replayVideo];
            break;
        default:
            [self.player replayVideo];
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
