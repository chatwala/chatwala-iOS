//
//  CWMessageItem.m
//  Sender
//
//  Created by Khalid on 11/7/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageItem.h"



@implementation CWMessageItem





- (id)init
{
    self=[super init];
    if (self) {
        
        self.zipURL = [NSURL fileURLWithPath:[[self cacheDirectoryPath]stringByAppendingPathComponent:MESSAGE_FILENAME]];
        self.metadata = [[CWMetadata alloc]init];
        [self.metadata setTimestamp:[NSDate date]];
        [self.metadata setSenderId:@"unknown_sender"];
        [self.metadata setRecipientId:@"unknown_recipient"];
        
         
        [self.metadata setMessageId:[[NSUUID UUID]UUIDString]];
        [self.metadata setThreadId:[[NSUUID UUID]UUIDString]];
        [self.metadata setThreadIndex:0];
        [self.metadata setVersionId:FILE_VERSION];
        [self.metadata setStartRecording:0];
    }
    return self;
}
- (NSString*)cacheDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)exportZip
{
    // validate everything is set
    
    
    [self createChatwalaFile];
}

- (void)extractZip
{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:self.zipURL.path]) {
        NSLog(@"zip not found at path: %@",self.zipURL.path);
        return;
    }
    NSString * destPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:INCOMING_DIRECTORY_NAME];
    [SSZipArchive unzipFileAtPath:self.zipURL.path toDestination:destPath];
    
    NSString * metadataFileName = [destPath stringByAppendingPathComponent:METADATA_FILE_NAME];
    if ([fm fileExistsAtPath:destPath]) {
        if ([fm fileExistsAtPath:metadataFileName isDirectory:NO]) {
            NSError * error = nil;
            NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:metadataFileName] options:0 error:&error];
            if (error) {
                NSLog(@"failed to parse json metdata: %@",error.debugDescription);
                return;
            }
            self.metadata = [MTLJSONAdapter modelOfClass:[CWMetadata class] fromJSONDictionary:jsonDict error:&error];
            if (error) {
                NSLog(@"failed to json object to metdata: %@",error.debugDescription);
                return;
            }
        }else{
            NSLog(@"could not find json file at %@",metadataFileName);
            return;
        }
        
        
        // set video url
        [self setVideoURL:[NSURL fileURLWithPath:[destPath stringByAppendingPathComponent:VIDEO_FILE_NAME]]];
    }
    
    
}

- (void)createChatwalaFile
{
    
    NSString * newDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:OUTGOING_DIRECTORY_NAME];
    
    NSError * err = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:newDirectoryPath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:newDirectoryPath error:&err];
    }
    if (err) {
        NSLog(@"error removing new file directory: %@",err.debugDescription);
        return;
    }
    
    
    
    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:YES attributes:nil error:&err];
    if (err) {
        NSLog(@"error creating new file directory: %@",err.debugDescription);
        return;
    }
    
    
    NSAssert(self.videoURL.path, @"video path must not be nil");
    // copy video to folder
    [[NSFileManager defaultManager]copyItemAtPath:self.videoURL.path toPath:[newDirectoryPath stringByAppendingPathComponent:VIDEO_FILE_NAME] error:&err];
    if (err) {
        NSLog(@"faild to copy video to new directory: %@",err.debugDescription);
        return;
    }
    
    // create json file
    
    NSDictionary * jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:self.metadata];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&err];
    
    if (err) {
        NSLog(@"faild to create JSON metadata: %@",err.debugDescription);
        return;
    }
    
    [jsonData writeToFile:[newDirectoryPath stringByAppendingPathComponent:METADATA_FILE_NAME] atomically:YES];
    
    
    NSLog(@"ready!");
    // zip it up
    
    [SSZipArchive createZipFileAtPath:self.zipURL.path withContentsOfDirectory:newDirectoryPath];
    
}

@end
