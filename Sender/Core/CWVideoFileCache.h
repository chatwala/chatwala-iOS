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

- (NSString *)inboxFilepathForKey:(NSString *)messageID;
- (NSString *)sentBoxFilepathForKey:(NSString *)messageID;
- (NSString *)outBoxFilepathForKey:(NSString *)messageID;
//- (NSString *)moveVideoToSentBox:(NSString *)messageID;


- (uint64_t)freeCacheSpaceInBytes;
- (BOOL)hasMinimumFreeDiskSpace;
- (void)purgeCache;  // Clears all data within the base cache folder

// Should move these to their own class that manages this video cache object
+  (NSString *)baseInboxFilepath;
+  (NSString *)baseSentBoxFilepath;
+  (NSString *)baseOutBoxFilepath;
+  (NSString *)baseTempFilepath;

@end