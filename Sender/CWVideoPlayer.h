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


static void *CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext = &CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext;
static void *CWVideoPlayerPlaybackViewControllerStatusObservationContext = &CWVideoPlayerPlaybackViewControllerStatusObservationContext;

@interface CWVideoPlayer : NSObject
@property (nonatomic,weak) id<CWVideoPlayerDelegate> delegate;
@property (nonatomic,strong) CWVideoPlayerView * playbackView;

- (void)setVideoURL:(NSURL*)URL;
- (void)playVideo;
- (void)stop;
- (void)replayVideo;
- (NSTimeInterval) videoLength;
- (void) createStillForLastFrameWithCompletionHandler:(void (^)(UIImage * thumbnail)) completionHandler;
- (void) createProfilePictureThumbnailWithCompletionHandler:(void (^)(UIImage * thumbnail)) completionHandler;
-(void)cleanUp;
@end



@protocol CWVideoPlayerDelegate <NSObject>
- (void)videoPlayerDidLoadVideo:(CWVideoPlayer*)videoPlayer;
- (void)videoPlayerFailedToLoadVideo:(CWVideoPlayer *)videoPlayer withError:(NSError*)error;
- (void)videoPlayerPlayToEnd:(CWVideoPlayer*)videoPlayer;
@end