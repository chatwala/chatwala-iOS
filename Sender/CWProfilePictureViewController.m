//
//  CWProfilePictureViewController.m
//  Sender
//
//  Created by randall chatwala on 1/16/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWProfilePictureViewController.h"
#import "CWUserManager.h"
#import "User.h"
#import "CWVideoManager.h"
#import "UIImageView+AFNetworking.h"

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
    [self.navigationItem setTitle:@"UPDATE PROFILE PIC"];
    
    UIImage * backImg = [UIImage imageNamed:@"back_button"];
    UIButton * backBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:backImg forState:UIControlStateNormal];
    UIBarButtonItem* backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:backBtnItem];
    
    [[[CWVideoManager sharedManager]recorder]setupSession];

    self.pictureImageView.image = [UIImage imageNamed:@"LaunchImage"];
    [self.pictureImageView setClipsToBounds:YES];
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view insertSubview:[[[CWVideoManager sharedManager] recorder] recorderView] belowSubview:self.pictureImageView];
    [[[[CWVideoManager sharedManager] recorder] recorderView ]setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.5)];

    
//    self.pictureImageView setImageWithURLRequest:<#(NSURLRequest *)#> placeholderImage:<#(UIImage *)#> success:<#^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)success#> failure:<#^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)failure#>

}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) isTakingNewPicture
{
    return self.pictureImageView.isHidden;
}

- (void) takePicture
{
    
    [[[CWVideoManager sharedManager] recorder] captureStillImageWithCallback:^(UIImage *image, NSError *error) {
        if(error)
        {
            NSLog(@"failed to capture image %@", error);
            [SVProgressHUD showErrorWithStatus:@"failed to capture image"];
        }
        else
        {
            [self didCaptureStillImage:image];
        }
    }];
    
    self.pictureImageView.hidden = NO;
    [self.middleButton setTitle:@"Change!" forState:UIControlStateNormal];
    self.bottomDescription.text = @"Tap Change! to update your profile pic.";
}

- (void) didCaptureStillImage:(UIImage *) image
{
    self.pictureImageView.image = image;
    if([[CWUserManager sharedInstance] hasLocalUser])
    {
        [[CWUserManager sharedInstance] localUser:^(User *localUser) {
            [[CWUserManager sharedInstance] uploadProfilePicture:image forUser:localUser];
        }];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"no user id yet"];
    }
}

- (void) startCamera
{
    self.pictureImageView.hidden = YES;
    [self.middleButton setTitle:@"SNAP!" forState:UIControlStateNormal];
    self.bottomDescription.text = @"Tap SNAP! to take a picture.";
}

- (IBAction)onMiddleButtonTap:(id)sender {
    if([self isTakingNewPicture])
    {
        [self takePicture];
    }
    else
    {
        [self startCamera];
    }
}

@end
