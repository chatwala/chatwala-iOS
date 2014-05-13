//
//  CWLoadingViewController.h
//  Sender
//
//  Created by Khalid on 12/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


@interface CWLoadingViewController : UIViewController

@property (nonatomic,strong) IBOutlet UILabel *loadingLabel;

- (void)restartAnimation;
- (void)stopAnimating;

@end
