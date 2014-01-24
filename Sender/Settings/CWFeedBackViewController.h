//
//  CWFeedBackViewController.h
//  Sender
//
//  Created by Susan Cudmore on 1/24/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWSettingsBaseViewController.h"

@interface CWFeedBackViewController : CWSettingsBaseViewController

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) IBOutlet UIButton *noButton;

- (IBAction)onYesTapped:(id)sender;
- (IBAction)onNoTapped:(id)sender;
@end
