//
//  CWRatingViewController.h
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWSettingsBaseViewController.h"

@interface CWRatingViewController : CWSettingsBaseViewController
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *sureButton;

- (IBAction)sureButtonTapped:(id)sender;
@end