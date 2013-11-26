//
//  CWFlowManager.h
//  Sender
//
//  Created by Khalid on 11/22/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWStartScreenViewController.h"
#import "CWOpenerViewController.h"
#import "CWComposerViewController.h"

typedef enum {
    eFlowToOpener,
    eFlowToStartScreen,
}eFlow;


@interface CWFlowManager : NSObject
+ (instancetype) sharedInstance;

- (CWStartScreenViewController*)startScreenVC;
- (CWOpenerViewController*)openerVC;
- (CWComposerViewController*)composeVC;

@end
