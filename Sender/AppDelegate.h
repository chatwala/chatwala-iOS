//
//  AppDelegate.h
//  Sender
//
//  Created by Khalid on 11/5/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CWLandingViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) CWLandingViewController * landingVC ;
@property (nonatomic,strong) UINavigationController * navController;
@property (nonatomic,strong) MMDrawerController * drawController;
@property (nonatomic,assign) BOOL isDrawOpen;
@end
