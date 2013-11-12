//
//  CWVideoPlayer.m
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWVideoPlayer.h"
#import "CWVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>





@interface CWVideoPlayer ()
{
    NSURL * _videoURL;
}
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVURLAsset *asset;
@end


@implementation CWVideoPlayer

- (id)init
{
    self = [super init];
    if (self) {
        self.playbackView = [[CWVideoPlayerView alloc]init];
    }
    return self;
}

- (void)dealloc
{
    
    // remove old listeners
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    if (self.player) {
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    }
    
    self.delegate = nil;
    self.playbackView = nil;
    self.player = nil;
    self.playerItem = nil;
}

- (void)setVideoURL:(NSURL *)URL
{
    _videoURL = URL;
    // check if video file exists
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:URL.path];
    if (!videoFileExists) {
        NSError * videoURLError = [NSError errorWithDomain:@"CWVideoPlayer" code:0 userInfo:@{@"description": @"video file not found"}];
        if ([self.delegate respondsToSelector:@selector(videoPlayerFailedToLoadVideo:withError:)]) {
            [self.delegate videoPlayerFailedToLoadVideo:self withError:videoURLError];
        }
        return;
    }
    
    
    // load the video asset
    self.asset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    [self.asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
            [self prepareToPlayAsset:self.asset withKeys:requestedKeys];
     }];
}

- (void)play
{
    [self.player play];
}

- (void)replay{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
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
    
    
    [self setupPlayerItemWithAsset:asset];
    [self setupPlayerWithAsset:asset];
    
    
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    
}


- (void)setupPlayerItemWithAsset:(AVAsset*)asset
{
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    
    // setup player item
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext];
    
    id obs = [self.playerItem observationInfo];
    NSLog(@"observationInfo: %@",obs);
}


- (void)setupPlayerWithAsset:(AVAsset*)asset
{
    if (self.player) {
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    }
    
    
    
    
    // setup player
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [self.player addObserver:self forKeyPath:kCurrentItemKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:CWVideoPlayerPlaybackViewControllerStatusObservationContext];
}


- (void)playerItemDidReachEnd:(NSNotification*)note
{
    
    // inform the delegate (if registered)
    if ([self.delegate respondsToSelector:@selector(videoPlayerPlayToEnd:)]) {
        [self.delegate videoPlayerPlayToEnd:self];
    }
}


#pragma mark - Key Valye Observing

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
	if (context == CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext) {
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
            [self.playbackView setPlayer:self.player];
            [self.playbackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
	} else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


@end
