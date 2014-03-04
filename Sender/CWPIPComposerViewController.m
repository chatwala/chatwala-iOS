//
//  CWPIPComposerViewController.m
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWPIPComposerViewController.h"
#import "CWPIPReviewViewController.h"
@interface CWPIPComposerViewController ()

@end

@implementation CWPIPComposerViewController


- (void)showPreview {

    CWPIPReviewViewController * reviewVC = [[CWPIPReviewViewController alloc]init];
    [reviewVC setStartRecordingTime:0];
    [self.navigationController pushViewController:reviewVC animated:YES];
}

@end
