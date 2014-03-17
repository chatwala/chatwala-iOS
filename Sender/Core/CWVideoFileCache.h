//
//  CWFileCache.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/3/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

@interface CWVideoFileCache : NSObject

// TODO:    1) needs some type of max size here
//          2) cache deletion when max size is met or file becomes obsolete

+ (CWVideoFileCache *)sharedCache;
+ (NSString *)baseCacheDirectoryFilepath;

- (NSError *)storeVideoDataFromURL:(NSURL *)tempURL forKey:(NSString *)messageID mimeType:(NSString *)type;
- (NSString *)filepathForKey:(NSString *)messageID;

- (uint64_t)freeCacheSpaceInBytes;
- (void)purgeCache;  // Clears all data within the base cache folder

@end
