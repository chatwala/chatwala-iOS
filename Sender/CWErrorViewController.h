//
//  CWErrorViewController.h
//  Sender
//
//  Created by Khalid on 11/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWErrorViewController : UIViewController
@property (nonatomic,strong) NSError * error;
- (IBAction)onGrantAccess:(id)sender;
@end
