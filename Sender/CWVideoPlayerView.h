//
//  CWVideoPlayerView.h
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;

@interface CWVideoPlayerView : UIView
@property (nonatomic, retain) AVPlayer *player;
- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;
@end
