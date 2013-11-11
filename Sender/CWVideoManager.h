//
//  CWVideoManager.h
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWVideoManager : NSObject
+(instancetype) sharedManager;
@property (nonatomic,strong) id recorder;
@property (nonatomic,strong) id player;
@end
 