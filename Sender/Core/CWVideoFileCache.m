//
//  CWFileCache.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/3/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWVideoFileCache.h"

#ifdef USE_DEV_SERVER
long const MinimumFreeDiskSpace = 1073741824;
#elif defined(USE_QA_SERVER)
long const MinimumFreeDiskSpace = 1073741824;
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
        [shared createFileDirectories];
    });
    
    return shared;
}

#pragma mark - Public API

- (NSString *)inboxDirectoryPathForKey:(NSString *)messageID {
    
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
}

- (NSString *)sentboxDirectoryPathForKey:(NSString *)messageID {
    
    NSString * localPath = [[CWVideoFileCache baseSentBoxFilepath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",messageID]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating sent file directory: %@", error.debugDescription);
            return nil;
        }
    }
    
    return localPath;
}

- (NSString *)outboxDirectoryPathForKey:(NSString *)messageID {
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
    NSLog(@"Max Disk Space: %lu.", MinimumFreeDiskSpace);
    return [self freeCacheSpaceInBytes] > MinimumFreeDiskSpace;
}

- (void)purgeCache {
    NSLog(@"Purging all cached data");
    [self purgeLegacyFiles];
    [self purgeInbox];
    [self purgeSentbox];
}

#pragma mark - Purge Convenience methods

- (void)purgeLegacyFiles {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:documentDirectory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", documentDirectory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
    
    // Delete all the legacy MP4 files in the base caches directory
    NSString *cacheDirectory = [CWVideoFileCache baseCacheDirectoryFilepath];
    NSArray *allFiles = [fm contentsOfDirectoryAtPath:cacheDirectory error:nil];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mp4' || self ENDSWITH '.zip'"];
    NSArray *mp4Files = [allFiles filteredArrayUsingPredicate:filter];
    
    for (NSString *mp4File in mp4Files) {
        NSError *error = nil;
        [fm removeItemAtPath:[cacheDirectory stringByAppendingPathComponent:mp4File] error:&error];
    }
    
    // Remove legacy folder structure
    [fm removeItemAtPath:[documentDirectory stringByAppendingString:@"/incoming_message"] error:nil];
    [fm removeItemAtPath:[documentDirectory stringByAppendingString:@"/outgoing_message"] error:nil];
}

- (void)purgeInbox {

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [CWVideoFileCache baseInboxFilepath];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
            NSLog(@"Error deleting inbox file");
        }
    }
}

- (void)purgeSentbox {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [CWVideoFileCache baseSentBoxFilepath];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
        if (!success || error) {
            NSLog(@"Error deleting sentbox file");
        }
    }
}


#pragma mark - Static Convenience to return base paths

+ (NSString *)baseCacheDirectoryFilepath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

// Should move these to their own class that manages this video cache object
+  (NSString *)baseInboxFilepath {
    
    NSString *cacheFilePath = [[CWVideoFileCache baseCacheDirectoryFilepath] stringByAppendingPathComponent:@"inbox"];
    return cacheFilePath;
}

+  (NSString *)baseSentBoxFilepath {
    NSString *cacheFilePath = [[CWVideoFileCache baseCacheDirectoryFilepath] stringByAppendingPathComponent:@"sent"];
    return cacheFilePath;
}

+  (NSString *)baseOutBoxFilepath {
    NSString *cacheFilePath = [[CWVideoFileCache baseCacheDirectoryFilepath] stringByAppendingPathComponent:@"outbox"];
    return cacheFilePath;
}

+  (NSString *)baseTempFilepath {
    NSString *cacheFilePath = [[CWVideoFileCache baseCacheDirectoryFilepath] stringByAppendingPathComponent:@"temp"];
    return cacheFilePath;
}

#pragma mark - Create Directory Structure

- (void)createFileDirectories {
    [self createInboxDirectory];
    [self createOutboxDirectory];
    [self createSentboxDirectory];
    [self createTempDirectory];
}


- (BOOL)createInboxDirectory {
    NSString *cacheFilePath = [CWVideoFileCache baseInboxFilepath];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating inbox file directory: %@", error.debugDescription);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)createOutboxDirectory {
    NSString *cacheFilePath = [CWVideoFileCache baseOutBoxFilepath];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating outbox file directory: %@", error.debugDescription);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)createSentboxDirectory {
    NSString *cacheFilePath = [CWVideoFileCache baseSentBoxFilepath];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating sent file directory: %@", error.debugDescription);
            return NO;
        }
    }
    
    return YES;
}


- (BOOL)createTempDirectory {
    NSString *cacheFilePath = [CWVideoFileCache baseTempFilepath];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFilePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error creating temp file directory: %@", error.debugDescription);
            return NO;
        }
    }
    
    return YES;
}

@end