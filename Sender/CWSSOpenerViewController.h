//
//  CWSSOpenerViewController.h
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWOpenerViewController.h"
@class CWMiddleButton;
@interface CWSSOpenerViewController : CWOpenerViewController
@property (weak, nonatomic) IBOutlet CWMiddleButton *middleButton;
@property (weak, nonatomic) IBOutlet UILabel *openerMessageLabel;
@end
