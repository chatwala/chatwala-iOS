//
//  CWVideoPlayer.h
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWVideoPlayerView.h"

@protocol CWVideoPlayerDelegate;
/* Asset keys */
extern NSString * const kTracksKey;
extern NSString * const kPlayableKey;

/* PlayerItem keys */
extern NSString * const kStatusKey;
extern NSString * const kCurrentItemKey;

static void *CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext = &CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext;
static void *CWVideoPlayerPlaybackViewControllerStatusObservationContext = &CWVideoPlayerPlaybackViewControllerStatusObservationContext;

@interface CWVideoPlayer : NSObject
@property (nonatomic,weak) id<CWVideoPlayerDelegate> delegate;
@property (nonatomic,strong) CWVideoPlayerView * playbackView;

- (void)setVideoURL:(NSURL*)URL;
- (void)play;
- (void)stop;
@end



@protocol CWVideoPlayerDelegate <NSObject>
- (void)videoPlayerDidLoadVideo:(CWVideoPlayer*)videoPlayer;
- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError*)error;
- (void)videoPlayerPlayToEnd:(CWVideoPlayer*)videoPlayer;
@end