//
//  CWFileCache.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/3/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWVideoFileCache.h"


long const MinimumFreeDiskSpace = 10485760;

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

- (NSString *)filepathForKey:(NSString *)messageID {
    
    NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[messageID stringByAppendingString:@".zip"]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {

        return localPath;
    }
    else {
        return nil;
    }
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
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

@end