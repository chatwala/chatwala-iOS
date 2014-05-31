//
//  CWStartKnownRecipientViewController.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 5/22/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWStartKnownRecipientViewController.h"
#import "CWMiddleButton.h"
#import "CWSSComposerViewController.h"
#import "CWVideoFileCache.h"
#import "CWGroundControlManager.h"

@interface CWStartKnownRecipientViewController () <UIGestureRecognizerDelegate>

@property (nonatomic) CWMiddleButton *middleButton;
@property (nonatomic) UIImageView *profilePictureView;

@property (nonatomic) UILabel *bottomHalfLabel;

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic) BOOL shouldUseBackCamera;

@end

@implementation CWStartKnownRecipientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.bottomHalfLabel = [[UILabel alloc] init];
    self.bottomHalfLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20.0f];
    self.bottomHalfLabel.backgroundColor = [UIColor clearColor];
    self.bottomHalfLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomHalfLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.bottomHalfLabel.clipsToBounds = YES;
    [self.view addSubview:self.bottomHalfLabel];
    
    [self.view addSubview:self.bottomHalfLabel];
    
    self.middleButton = [[CWMiddleButton alloc] init];
    [self.middleButton setAutoresizesSubviews:YES];
    [self.middleButton setClearsContextBeforeDrawing:YES];
    [self.middleButton setOpaque:YES];
    [self.middleButton setBackgroundColor:[UIColor clearColor]];
    [self.middleButton setAlpha:1.0f];
    [self.view addSubview:self.middleButton];

    [self setNavMode:NavModeBurger];
    [self.navigationItem setHidesBackButton:YES];
    [self.middleButton.button addTarget:self action:@selector(onMiddleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // single tap gesture recognizer
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggledCamera:)];
    [self.tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.bottomHalfLabel.frame = CGRectMake(0.0f, 0.0f, 247.0f, 163.0f);
    [self.bottomHalfLabel setCenter:CGPointMake(self.view.center.x, (self.view.center.y + self.view.frame.size.height) / 2.0f)];
    self.bottomHalfLabel.frame = CGRectIntegral(self.bottomHalfLabel.frame);
    [self.bottomHalfLabel setText:[[CWGroundControlManager sharedInstance] startScreenMessage]];
    
    self.middleButton.frame = CGRectMake(0.0f, 0.0f, 90.0f, 90.0f);
    
    [self.middleButton setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [self.middleButton setButtonState:eButtonStateStop];
    [self.middleButton setUserInteractionEnabled:YES];
    [self.view bringSubviewToFront:self.middleButton];
    
    [self.middleButton setButtonState:eButtonStateRecord];
    [[[[CWVideoManager sharedManager] recorder] recorderView] setAlpha:1.0f];
    
    [self configureRecipientPicture];
}

- (void)configureRecipientPicture {
    
    if (self.recipientPicture) {
        self.profilePictureView = [[UIImageView alloc] initWithImage:self.recipientPicture];
        self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
        self.profilePictureView.clipsToBounds = YES;
        self.profilePictureView.frame = CGRectMake(0.0f, self.view.center.y, self.view.bounds.size.width, self.view.bounds.size.height / 2.0f);
        self.profilePictureView.frame = CGRectIntegral(self.profilePictureView.frame);
        self.profilePictureView.alpha = 0.5f;
        [self.view insertSubview:self.profilePictureView belowSubview:self.middleButton];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[[CWVideoManager sharedManager] recorder] checkForMicAccess];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.middleButton];
    [[[[CWVideoManager sharedManager] recorder] recorderView] setFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    
}

- (void)onMiddleButtonTapped:(id)sender {
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        [SVProgressHUD showErrorWithStatus:@"Internet connection required\n to send message."];
        return;
    }
    else if (![[CWVideoFileCache sharedCache] hasMinimumFreeDiskSpace])  {
        [SVProgressHUD showErrorWithStatus:@"Please free up disk space! Unable to record new message."];
        return;
    }
    
    [CWAnalytics event:@"START_RECORDING" withCategory:@"CONVERSATION_STARTER" withLabel:@"TAP_BUTTON" withValue:nil];
    CWSSComposerViewController * composerVC = [[CWSSComposerViewController alloc] init];
    composerVC.recipientID = self.recipientID;
    composerVC.recipientPicture = self.recipientPicture;
    [self.navigationController pushViewController:composerVC animated:NO];
    
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGPoint pointInView = [touch locationInView:gestureRecognizer.view];
    
    if ([gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]
        && CGRectContainsPoint(CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height * 0.5f), pointInView) ) {
        
        if (!CGRectContainsPoint(self.middleButton.frame, pointInView)) {
            return YES;
        }
    }
    
    return NO;
}

- (void)toggledCamera:(UIGestureRecognizer *)recognizer {
    
    NSLog(@"Record screen tapped from start screen");
    self.shouldUseBackCamera = !self.shouldUseBackCamera;
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:(self.shouldUseBackCamera ? [CWVideoRecorder backFacingCamera] : [CWVideoRecorder frontFacingCamera]) error:nil];
    [[[CWVideoManager sharedManager] recorder] changeVideoInput:videoInput];
}

@end