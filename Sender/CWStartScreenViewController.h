//
//  CWStartScreenViewController.h
//  Sender
//
//  Created by Khalid on 11/8/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWStartScreenViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)onStart:(id)sender;
- (IBAction)onAuthenticate:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
@end
