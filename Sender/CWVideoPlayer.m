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

@interface CWVideoPlayer ()
@end


@implementation CWVideoPlayer



- (void)setVideoURL:(NSURL *)URL
{
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
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
    
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

    // inform the delegate (if registered)
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidLoadVideo:)]) {
        [self.delegate videoPlayerDidLoadVideo:self];
    }
    
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
    
    
    
    
    
}

@end
