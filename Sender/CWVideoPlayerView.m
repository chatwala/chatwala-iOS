//
//  CWVideoPlayerView.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CWVideoPlayerView

+ (Class)layerClass {
	return [AVPlayerLayer class];
}

- (AVPlayer*)player {
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player {
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode {
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}
@end
