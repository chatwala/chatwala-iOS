//
//  AppDelegate.h
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWSSOpenerViewController.h"

@class CWLandingViewController;
@class CWNavigationViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) UINavigationController * navController;
@property (nonatomic,strong) MMDrawerController * drawController;
@property (nonatomic,assign) BOOL isDrawOpen;

@end
