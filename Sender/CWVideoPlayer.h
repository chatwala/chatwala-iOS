//
//  CWVideoPlayer.h
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CWVideoPlayerDelegate;

@interface CWVideoPlayer : NSObject
@property (nonatomic,weak) id<CWVideoPlayerDelegate> delegate;
- (void)setVideoURL:(NSURL*)URL;
- (void)play;
- (void)stop;
@end



@protocol CWVideoPlayerDelegate <NSObject>
- (void)videoPlayerDidLoadVideo:(CWVideoPlayer*)videoPlayer;
- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError*)error;
@end