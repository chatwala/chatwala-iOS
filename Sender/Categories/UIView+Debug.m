//
//  UIView+Debug.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 5/30/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "UIView+Debug.h"

@implementation UIView (Debug)

- (void)toggleBorder:(BOOL)enableBorder {
    
    if (enableBorder) {
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }
    else {
        self.layer.borderWidth = 0.0f;
    }
    
}

@end
