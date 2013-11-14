//
//  CWOpenerViewController.h
//  Sender
//
//  Created by Khalid on 11/14/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWOpenerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *playbackView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,strong) NSURL * zipURL;
@end
