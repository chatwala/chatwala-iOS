//
//  CWProfilePictureViewController.m
//  Sender
//
//  Created by randall chatwala on 1/16/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWProfilePictureViewController.h"
#import "CWUserManager.h"
#import "CWVideoManager.h"
#import "UIImageView+AFNetworking.h"
#import <AFNetworking/AFNetworking.h>
#import "CWConstants.h"
#import "CWServerAPI.h"
#import "CWUserDefaultsController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

@interface CWProfilePictureViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomDescription;
@property (weak, nonatomic) IBOutlet UIView *flash;


@end

@implementation CWProfilePictureViewController

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
    [self setTitle:@"UPDATE PROFILE PIC"];
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[CWVideoRecorder frontFacingCamera] error:nil];
    [[[CWVideoManager sharedManager] recorder] changeVideoInput:videoInput];

    self.pictureImageView.image = [UIImage imageNamed:@"LaunchImage"];
    [self.pictureImageView setClipsToBounds:YES];
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.pictureImageView.superview insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.pictureImageView];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.00] forKey:kCATransactionAnimationDuration];
    //Perform CALayer actions, such as changing the layer contents, position, whatever.
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:self.pictureImageView.frame];
    [CATransaction commit];

    
    
    if([[CWUserManager sharedInstance] localUserID]) {

        NSURL *profilePictureURL = [CWUserDefaultsController profilePictureReadURL];
        if (profilePictureURL) {
            
            [self fetchProfilePictureFromReadURL:profilePictureURL];
        }
        else {
            
            [self fetchReadURLAndLoadProfilePicture];
        }
    }
}

#pragma mark - Profile Picture 

- (void)fetchReadURLAndLoadProfilePicture {

    [CWServerAPI getProfilePictureReadURLForUser:[[CWUserManager sharedInstance] localUserID] withCompletionBlock:^(NSURL *profilePictureReadURL) {
        
        if (profilePictureReadURL) {
            [CWUserDefaultsController setProfilePictureReadURL:profilePictureReadURL];
            [self fetchProfilePictureFromReadURL:profilePictureReadURL];
        }
    }];
}

- (void)fetchProfilePictureFromReadURL:(NSURL *)pictureURL {
    
    SDWebImageDownloader *manager = [SDWebImageManager sharedManager].imageDownloader;
    [manager setValue:[NSString stringWithFormat:@"%@:%@", CWConstantsChatwalaAPIKey, CWConstantsChatwalaAPISecret] forHTTPHeaderField:CWConstantsChatwalaAPIKeySecretHeaderField];
    
    [self.pictureImageView setImageWithURL:pictureURL
                          placeholderImage:[UIImage imageNamed:@"LaunchImage"]
                                   options:SDWebImageRetryFailed | SDWebImageRefreshCached
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     // Need a completion block
                                 }];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) isTakingNewPicture {
    return self.pictureImageView.isHidden;
}

- (void) takePicture
{
    self.flash.alpha = 1;
    
    [[[CWVideoManager sharedManager] recorder] captureStillImageWithCallback:^(UIImage *image, NSError *error) {
        if(error)
        {
            NSLog(@"failed to capture image %@", error);
        }
        else
        {
            [self didCaptureStillImage:image];
        }
        [UIView animateWithDuration:.2 animations:^{
            self.flash.alpha = 0;
        }];
    }];
    
    self.pictureImageView.hidden = NO;
    [self.middleButton setTitle:@"Change!" forState:UIControlStateNormal];
    self.bottomDescription.text = @"Tap Change! to update your profile pic.";
}

- (void)didCaptureStillImage:(UIImage *) image {
    
    [self.pictureImageView cancelImageRequestOperation];
    self.pictureImageView.image = image;

    NSString *localUserID = [[CWUserManager sharedInstance] localUserID];

    [[CWUserManager sharedInstance] uploadProfilePicture:image forUser:localUserID completion:^(NSError *error) {

        if(!error) {
            [[CWUserManager sharedInstance] approveProfilePicture:localUserID];
        }
    }];
}

- (void) startCamera {
    self.pictureImageView.hidden = YES;
    [self.middleButton setTitle:@"SNAP!" forState:UIControlStateNormal];
    self.bottomDescription.text = @"Tap SNAP! to take a picture.";
}

- (IBAction)onMiddleButtonTap:(id)sender {
    if([self isTakingNewPicture]) {
        [self takePicture];
    }
    else {
        [self startCamera];
    }
}

- (void) onSettingsDone:(id)sender {
    [super onSettingsDone:sender];
    [[CWUserManager sharedInstance] approveProfilePicture:[[CWUserManager sharedInstance] localUserID]];
}

@end
