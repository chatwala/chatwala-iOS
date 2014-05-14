//
//  CWFileCache.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/3/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

@interface CWVideoFileCache : NSObject

+ (CWVideoFileCache *)sharedCache;
+ (NSString *)baseCacheDirectoryFilepath;
+ (NSString *)baseTempFilepath;

- (NSString *)inboxDirectoryPathForKey:(NSString *)messageID;
- (NSString *)sentboxDirectoryPathForKey:(NSString *)messageID;
- (NSString *)outboxDirectoryPathForKey:(NSString *)messageID;

- (uint64_t)freeCacheSpaceInBytes;
- (BOOL)hasMinimumFreeDiskSpace;
- (void)purgeCache;  // Clears all data within the base cache folder

@end