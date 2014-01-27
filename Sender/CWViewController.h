//
//  CWViewController.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    NavModeNone,
    NavModeClose,
    NavModeBurger
}NavMode;
@interface CWViewController : UIViewController
- (void)setNavMode:(NavMode)mode;
- (void)onTap:(id)sender;

@property (nonatomic,strong) UIBarButtonItem * burgerButton;
@property (nonatomic,strong) UIBarButtonItem * closeButton;


-(void)rotateBurgerBarAfterDrawAnimation:(BOOL) isAfterAnimation;

@end
