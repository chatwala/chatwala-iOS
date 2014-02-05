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

/* Asset keys */
NSString * const kTracksKey = @"tracks";
NSString * const kPlayableKey = @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";
NSString * const kCurrentItemKey	= @"currentItem";




@interface CWVideoPlayer ()
{
    NSURL * _videoURL;
}
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVURLAsset *asset;

@property (nonatomic, strong) UIImage * profilePicture;
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
    self.profilePicture = nil;
    // check if video file exists
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:URL.path];
    if (!videoFileExists) {
        NSError * videoURLError = [NSError errorWithDomain:@"CWVideoPlayer" code:0 userInfo:@{@"description": @"video file not found"}];
        if ([self.delegate respondsToSelector:@selector(videoPlayerFailedToLoadVideo:withError:)]) {
            [self.delegate videoPlayerFailedToLoadVideo:self withError:videoURLError];
        }
        return;
    }
    
    if (self.asset) {
        self.asset = nil;
    }
    
    // load the video asset
    self.asset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];

    AVURLAsset * loadedAsset = self.asset;
    [self.asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         NSLog(@"loading asset %@",loadedAsset);
         if([self.asset isEqual:loadedAsset])
         {
            [self prepareToPlayAsset:self.asset withKeys:requestedKeys];
         }
     }];
}

- (void)playVideo
{
    [self.player play];
}

- (void)replayVideo{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)stop
{
    [self.player seekToTime:kCMTimeZero];
    [self.player pause];
}

- (NSTimeInterval) videoLength
{
    return CMTimeGetSeconds(self.playerItem.asset.duration);
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
        self.playerItem = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    // setup player item
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:CWVideoPlayerPlaybackViewControllerCurrentItemObservationContext];
    
//    id obs = [self.playerItem observationInfo];
//    NSLog(@"observationInfo: %@",obs);
}


- (void)setupPlayerWithAsset:(AVAsset*)asset
{
//    if (self.player) {
//        self.player = nil;
//    }
//    
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

-(void)cleanUp
{
    [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    [self.playerItem removeObserver:self forKeyPath:kStatusKey];
    self.player = nil;
    self.playerItem = nil;
}

#pragma mark - generate thumbnail

- (void) createProfilePictureThumbnailWithCompletionHandler:(void (^)(UIImage * thumbnail)) completionHandler
{
    if(self.profilePicture)
    {
        if(completionHandler)
        {
            completionHandler(self.profilePicture);
        }
        return;
    }
    [self createStillsForTime:kCMTimeZero withCompletionHandler:completionHandler];
}

- (void) createStillForLastFrameWithCompletionHandler:(void (^)(UIImage * thumbnail)) completionHandler
{
    NSAssert(self.asset, @"expecting asset to be set");
    CMTime lastFrame = self.asset.duration;
    [self createStillsForTime:lastFrame withCompletionHandler:completionHandler];
}

- (void) createStillsForTime:(CMTime) time withCompletionHandler:(void (^)(UIImage * thumbnail)) completionHandler
{
    AVAssetImageGenerator * imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:time]]
                                         completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                                                      if(result == AVAssetImageGeneratorSucceeded)
                                                      {
                                                          self.profilePicture = [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
                                                          completionHandler(self.profilePicture);
                                                      }
                                                  }];
    
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
            [self.playbackView setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
        }
	} else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


@end
