//
//  CWLandingViewController.h
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWFlowManager.h"

@interface CWLandingViewController : UIViewController
@property (nonatomic,assign) eFlow flowDirection;
@property (nonatomic,strong) NSURL * incomingMessageZipURL;
@end
