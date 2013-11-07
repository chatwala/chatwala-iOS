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
        
        self.zipURL = [NSURL fileURLWithPath:[[self cacheDirectoryPath]stringByAppendingPathComponent:@"message.chatwala"]];
        self.metadata = [[CWMetadata alloc]init];
        [self.metadata setTimestamp:[NSDate date]];
        [self.metadata setSenderId:[[NSUserDefaults standardUserDefaults] valueForKey:@"chatwala_local_user"]];
        [self.metadata setMessageId:[self createUUIDString]];
        [self.metadata setThreadId:[self createUUIDString]];
        [self.metadata setThreadIndex:0];
        [self.metadata setVersionId:@"1.0"];
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
    NSString * destPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"recieved_message"];
    [SSZipArchive unzipFileAtPath:self.zipURL.path toDestination:destPath];
    
    if ([fm fileExistsAtPath:destPath]) {
        [self setVideoURL:[NSURL fileURLWithPath:[destPath stringByAppendingPathComponent:@"video.mov"]]];
    }
    
    
}

- (void)createChatwalaFile
{
    
    NSString * newDirectoryPath = [[self cacheDirectoryPath] stringByAppendingPathComponent:@"temp_message"];
    
    NSError * err = nil;
    [[NSFileManager defaultManager]removeItemAtPath:newDirectoryPath error:&err];
    if (err) {
        NSLog(@"error removing new file directory: %@",err.debugDescription);
        return;
    }
    
    
    
    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath withIntermediateDirectories:YES attributes:nil error:&err];
    if (err) {
        NSLog(@"error creating new file directory: %@",err.debugDescription);
        return;
    }
    
    
    
    // copy video to folder
    [[NSFileManager defaultManager]moveItemAtPath:self.videoURL.path toPath:[newDirectoryPath stringByAppendingPathComponent:@"video.mov"] error:&err];
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
    
    [jsonData writeToFile:[newDirectoryPath stringByAppendingPathComponent:@"metadata.json"] atomically:YES];
    
    
    NSLog(@"ready!");
    // zip it up
    
    [SSZipArchive createZipFileAtPath:self.zipURL.path withContentsOfDirectory:newDirectoryPath];
    
}

- (NSString *)createUUIDString {
    // Returns a UUID
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidStr;
}

@end
