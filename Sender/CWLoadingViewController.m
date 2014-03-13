//
//  CWLoadingViewController.m
//  Sender
//
//  Created by Khalid on 12/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWLoadingViewController.h"

@interface CWLoadingViewController ()
@property (nonatomic,strong) UIImageView * stencilView;
@property (nonatomic,strong) UIImageView * wavesView;
@end

@implementation CWLoadingViewController

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
    [self.view setBackgroundColor:[UIColor colorFromHexString:@"#e7e0d7"]];
    UIImage * image = [UIImage imageNamed:@"loading_stencil"];
    UIImage * wavesImage = [UIImage imageNamed:@"waves0000"];
    
    NSMutableArray * frames = [NSMutableArray array];
    for (NSInteger i =0; i<30; i++) {
        [frames addObject:[UIImage imageNamed:[NSString stringWithFormat:@"waves%04ld",(long)i]]];
    }
    
    self.wavesView = [[UIImageView alloc]initWithImage:wavesImage];
    [self.wavesView setAnimationImages:[frames mutableCopy]];
    [self.wavesView setAnimationDuration:0.5];
    [self.wavesView setAnimationRepeatCount:0];
    
    self.wavesView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.stencilView = [[UIImageView alloc]initWithImage:image];
    [self.stencilView setFrame:self.view.bounds];
    [self.view addSubview:self.wavesView];
    [self.view addSubview:self.stencilView];
    
    [self restartAnimation];
}

- (void)restartAnimation
{
    [self.wavesView.layer removeAllAnimations];
    [self.wavesView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),  CGRectGetMidY(self.view.bounds)+150)];
    [self.wavesView startAnimating];
    [UIView animateWithDuration:12 animations:^{
        //
        [self.wavesView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds),  CGRectGetMidY(self.view.bounds))];
    } completion:^(BOOL finished) {
//        [self.wavesView stopAnimating];
    }];
    
    
}
@end
