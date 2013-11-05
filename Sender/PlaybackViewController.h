//
//  PlaybackViewController.h
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaybackViewController : UIViewController
@property (nonatomic,strong) NSURL * videoURL;
- (IBAction)onRecordAgain:(id)sender;
- (IBAction)onSend:(id)sender;
@end
