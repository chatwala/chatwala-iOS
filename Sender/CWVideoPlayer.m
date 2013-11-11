//
//  CWVideoPlayer.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

/* Asset keys */
extern NSString * const kTracksKey;
extern NSString * const kPlayableKey;

/* PlayerItem keys */
extern NSString * const kStatusKey;
extern NSString * const kCurrentItemKey;

static void *CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext = &CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext;
static void *CWVideoPlayerPlaybackViewControllerStatusObservationContext = &CWVideoPlayerPlaybackViewControllerStatusObservationContext;

@interface CWVideoPlayer ()
{
    NSURL * _videoURL;
}
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVPlayerItem *playerItem;
@end


@implementation CWVideoPlayer



- (void)setVideoURL:(NSURL *)URL
{
    _videoURL = URL;
    // check if video file exists
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:URL.path];
    if (!videoFileExists) {
        NSError * videoURLError = [NSError errorWithDomain:@"CWVideoPlayer" code:0 userInfo:@{@"description": @"video file not found"}];
        if ([self.delegate respondsToSelector:@selector(videoPlayerFailedToLoadVideo:withError:)]) {
//            [self.delegate videoPlayerFailedToLoadVideo:self withError:videoURLError];
        }
        return;
    }
    
    
    // load the video asset
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}

- (void)play
{
    
}

- (void)stop
{
    
}



- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {

    
    
    // process the requested keys
    
    for (NSString * reqKey in requestedKeys) {
        NSError * err = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:reqKey error:&err];
        if (err) {
            // error checking key status on asset
            if ([self.delegate respondsToSelector:@selector(videoPlayerFailedToLoadVideo:withError:)]) {
                [self.delegate videoPlayerFailedToLoadVideo:self withError:err];
            }
            return;
        }
        // retrieved status for key on asset
        if (keyStatus == AVKeyValueStatusFailed) {
            // failure on key
            
            NSError * keyFailError = [NSError errorWithDomain:AVErrorMediaTypeKey code:AVKeyValueStatusFailed userInfo:nil];
            if ([self.delegate respondsToSelector:@selector(videoPlayerFailedToLoadVideo:withError:)]) {
                [self.delegate videoPlayerFailedToLoadVideo:self withError:keyFailError];
            }
            return;
        }
    
    }
    
    // check to see if asset is playable
    if (!asset.playable) {
        return;
    }
    
    
    
    
    
    
    // remove old listeners
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    if (self.player) {
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    }
    
    
    // setup player item
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:CWVideoPlayerPlaybackViewControllerStatusObservationContext];
    
    // setup player
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [self.player addObserver:self forKeyPath:kCurrentItemKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:CWVideoPlayerPlaybackViewControllerStatusObservationContext];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    
}
- (void)playerItemDidReachEnd:(NSNotification*)note
{
    /*
    // inform the delegate (if registered)
    if ([self.delegate respondsToSelector:@selector(videoPlayerPlayToEnd:)]) {
        [self.delegate videoPlayerPlayToEnd:self];
    }
    
    */
}


#pragma mark - Key Valye Observing

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
	if (context == CWVideoPlayerPlaybackViewControllerStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            // inform the delegate (if registered)
            if ([self.delegate respondsToSelector:@selector(videoPlayerDidLoadVideo:)]) {
                [self.delegate videoPlayerDidLoadVideo:self];
            }
        }
	} else if (context == CWVideoPlayerPlaybackViewControllerStatusObservationContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem) {
//            [self.playerView setPlayer:self.player];
//            [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
	} else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


@end
