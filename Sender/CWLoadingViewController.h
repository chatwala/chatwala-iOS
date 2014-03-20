//
//  CWLoadingViewController.h
//  Sender
//
//  Created by Khalid on 12/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWServerAPI.h"

@interface CWLoadingViewController : UIViewController

- (void)restartAnimation;
- (CWServerAPIDownloadProgressBlock)progressBlock;

@end
