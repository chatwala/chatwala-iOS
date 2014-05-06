//
//  CWFileCache.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/3/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWVideoFileCache.h"

#ifdef USE_DEV_SERVER
long const MinimumFreeDiskSpace = 73741824;
#else
long const MinimumFreeDiskSpace = 104857600;
#endif

@interface CWVideoFileCache ()


@end

@implementation CWVideoFileCache


#pragma mark - Public API

+ (CWVideoFileCache *)sharedCache {
    static dispatch_once_t pred;
    static CWVideoFileCache *shared = nil;
    
    dispatch_once(&pred, ^{
        // Load the base URL using our configuration file - which MUST be loaded first thing when app starts
        shared = [[CWVideoFileCache alloc] init];

    });
    
    return shared;
}

- (NSString *)storeVideoDataFromURL:(NSURL *)tempURL forKey:(NSString *)messageID mimeType:(NSString *)type {

    return nil;
}

- (NSString *)inboxFilepathForKey:(NSString *)messageID {
    
    NSString * localPath = [[CWVideoFileCache baseInboxFilepath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",messageID]];

    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating inbox file directory: %@", error.debugDescription);
            return nil;
        }
    }
    
    
    return localPath;
//
//    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
//
//        return localPath;
//    }
//    else {
//        return nil;
//    }
}

- (NSString *)sentBoxFilepathForKey:(NSString *)messageID {
    
    NSString * localPath = [[CWVideoFileCache baseSentBoxFilepath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",messageID]];
    
//    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
//        NSError *error = nil;
//        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
//        if (error) {
//            NSLog(@"error creating sent file directory: %@", error.debugDescription);
//            return nil;
//        }
//    }
    
    return localPath;
}

- (NSString *)outBoxFilepathForKey:(NSString *)messageID {
    NSString * localPath = [[CWVideoFileCache baseOutBoxFilepath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",messageID]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating outbox file directory: %@", error.debugDescription);
            return nil;
        }
    }

    
    return localPath;
}

- (uint64_t)freeCacheSpaceInBytes {
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;

    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[CWVideoFileCache baseCacheDirectoryFilepath]  error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MB with %llu MB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    }
    else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ldl", [error domain], (long)[error code]);
    }

    return totalFreeSpace;
}

- (BOOL)hasMinimumFreeDiskSpace {
    return [self freeCacheSpaceInBytes] > MinimumFreeDiskSpace;
}

- (void)purgeCache {
    NSLog(@"Purging all cached data");
    
    NSError *error = nil;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CWVideoFileCache baseCacheDirectoryFilepath] error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [[CWVideoFileCache baseCacheDirectoryFilepath] stringByAppendingPathComponent:path];
            BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                // Error handling
                NSLog(@"Failed to purge all cached data");
            }
        }
    }
    else {
        NSLog(@"Failed to purge cached data");
    }
}

+ (NSString *)baseCacheDirectoryFilepath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

// Should move these to their own class that manages this video cache object
+  (NSString *)baseInboxFilepath {
    
    NSMutableString *cacheFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [cacheFilePath stringByAppendingString:@"/inbox"];
}

+  (NSString *)baseSentBoxFilepath {
    NSString *cacheFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/sent"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating sent file directory: %@", error.debugDescription);
            return nil;
        }
    }
    
    return cacheFilePath;
}

+  (NSString *)baseOutBoxFilepath {
    NSString *cacheFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"outbox"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating outbox file directory: %@", error.debugDescription);
            return nil;
        }
    }
    return cacheFilePath;
}

+  (NSString *)baseTempFilepath {
    NSString *cacheFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"temp"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating temp file directory: %@", error.debugDescription);
            return nil;
        }
    }
    return cacheFilePath;
}

@end