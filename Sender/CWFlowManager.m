//
//  CWFlowManager.m
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWFlowManager.h"
#import "CWSSStartScreenViewController.h"
#import "CWPIPStartScreenViewController.h"
#import "CWSSOpenerViewController.h"
#import "CWPIPOpenerViewController.h"
#import "CWSSComposerViewController.h"
#import "CWPIPComposerViewController.h"

@interface CWFlowManager ()
@property (nonatomic,assign) BOOL isSplitScreen;
@end


@implementation CWFlowManager
+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] init];
    });
    return shared;
}

- (id)init
{
    self=[super init];
    if (self) {
        
        self.isSplitScreen = YES;
    }
    return self;
}

- (CWStartScreenViewController *)startScreenVC
{
    if (self.isSplitScreen) {
        return [[CWSSStartScreenViewController alloc]init];
    }else{
        return [[CWPIPStartScreenViewController alloc]init];
    }
}

- (CWOpenerViewController *)openerVC
{
    if (self.isSplitScreen) {
        return [[CWSSOpenerViewController alloc]init];
    }else{
        return [[CWPIPOpenerViewController alloc]init];
    }
}

- (CWComposerViewController *)composeVC
{
    if (self.isSplitScreen) {
        return [[CWSSComposerViewController alloc]init];
    }else{
        return [[CWPIPComposerViewController alloc]init];
    }
}

@end
