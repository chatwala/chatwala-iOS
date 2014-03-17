#import "Message.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"
#import "NSDictionary+LookUpTable.h"

@interface Message ()

@end


@implementation Message
@synthesize videoURL;
@synthesize zipURL;
@synthesize lastFrameImage;

// Custom logic goes here.

+ (NSDictionary *) keyLookupTable
{
    return @{
             @"group_id" : MessageAttributes.groupID,
             @"replying_to_message_id" : MessageAttributes.replyToMessageID,
             @"thread_id" : MessageRelationships.thread,
             @"thread_index" : MessageAttributes.threadIndex,
             @"message_id" : MessageAttributes.messageID,
             @"recipient_id" : MessageRelationships.recipient,
             @"sender_id" : MessageRelationships.sender,
             @"thumbnail_url" : MessageAttributes.thumbnailPictureURL,
             @"timestamp" : MessageAttributes.timeStamp,
             @"start_recording" : MessageAttributes.startRecording,
             @"share_url" :  MessageAttributes.messageURL,
             @"read_url"  : MessageAttributes.readURL,
             };
}

- (eMessageViewedState) eMessageViewedState
{
    NSInteger value = self.viewedStateValue;
    NSAssert(value < eMessageViewedStateTotal, @"expecting viewed state to be less than max enum value");
    NSAssert(value >= eMessageViewedStateInvalid, @"expecting viewed state to be less than max enum value");
    return (eMessageViewedState)value;
    
}
- (void) setEMessageViewedState:(eMessageViewedState) eViewedState {
    
    // Only allow viewed state to progress in a single direction (a read message cannot become unread for example) [RK 021914]
    if(self.eMessageViewedState < eViewedState) {
        self.viewedStateValue = eViewedState;
        [self.managedObjectContext save:nil];
    }
}


- (eMessageDownloadState) eDownloadState {
    NSInteger value = self.downloadStateValue;
    NSAssert(value < eMessageDownloadStateTotal, @"expecting download state to be less than max enum value");
    NSAssert(value >= eMessageDownloadStateInvalid, @"expecting download state to be less than max enum value");
    return (eMessageDownloadState)value;
}

- (void)setEMessageDownloadState:(eMessageDownloadState)eState {
    self.downloadStateValue = eState;
    [self.managedObjectContext save:nil];
}

- (void) exportZip
{
    NSString * newDirectoryPath = [[CWDataManager cacheDirectoryPath] stringByAppendingPathComponent:OUTGOING_DIRECTORY_NAME];
    
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
        NSLog(@"failed to copy video to new directory: %@",err.debugDescription);
        return;
    }
    
    // create json file
    
//    NSDictionary * jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:self.metadata];
    NSError * error = nil;
    NSData * jsonData = [self toJSONWithDateFormatter:[CWDataManager dateFormatter] error:&error];
    
    if (err) {
        NSLog(@"faild to create JSON metadata: %@",err.debugDescription);
        return;
    }
    
    [jsonData writeToFile:[newDirectoryPath stringByAppendingPathComponent:METADATA_FILE_NAME] atomically:YES];
    
    NSAssert(self.zipURL, @"expecting zip URL to be set");
    [SSZipArchive createZipFileAtPath:self.zipURL.path withContentsOfDirectory:newDirectoryPath];
}

- (NSDictionary *) toDictionaryWithDataFormatter:(NSDateFormatter *) dateFormatter error:(NSError **) error
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[super toDictionaryWithDataFormatter:dateFormatter error:error]];
    
    
    long long timeInterval = [@(floor([self.timeStamp timeIntervalSince1970] * 1000)) longLongValue];
    NSString *intervalString = [NSString stringWithFormat:@"%lli", timeInterval];
    
    [jsonDict setObject:intervalString forKey:MessageAttributes.timeStamp];

    
    NSDictionary *relationships = [[self entity] relationshipsByName];
    
    for (NSString *relation in relationships) {
        id value = [self valueForKey:relation];
        
        if (value == nil) {
            value = [NSNull null];
            continue;
        }
        NSRelationshipDescription * relationDescription = [relationships objectForKey:relation];
        
        NSEntityDescription * entityDescription = [relationDescription destinationEntity];
        
        if([entityDescription.name isEqualToString:[User entityName]])
        {
            User * user = value;
            value = user.userID;
        }
        else if([entityDescription.name isEqualToString:[Thread entityName]])
        {
            Thread * thread = value;
            value = thread.threadID;
        }
        else
        {
            NSAssert(0==1, @"unexpected relation: %@ with value: %@", relation, value);
        }
        
        [jsonDict setValue:value forKey:relation];
    }
    NSArray * whiteList = [self.class attributesAndRelationshipsToArchive];
    NSMutableArray * objectKeysToRemove = [jsonDict.allKeys mutableCopy];
    [objectKeysToRemove removeObjectsInArray:whiteList];
    [jsonDict removeObjectsForKeys:objectKeysToRemove];
    
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [jsonDict setObject:appVersion forKey:@"version_id"];
    
    return [NSDictionary dictionaryByReassignKeysOfDictionary:jsonDict withKeys:[Message reverseKeyLookupTable]];
}

+ (NSArray *) attributesAndRelationshipsToArchive
{
    return @[
             MessageAttributes.groupID,
             MessageAttributes.readURL,
             MessageAttributes.replyToMessageID,
             MessageAttributes.messageID,
             MessageAttributes.threadIndex,
             MessageAttributes.startRecording,
             MessageAttributes.timeStamp,
             MessageAttributes.thumbnailPictureURL,
             MessageRelationships.thread,
             MessageRelationships.recipient,
             MessageRelationships.sender,
             ];
}


+ (NSDictionary *) reverseKeyLookupTable
{
    return @{
             MessageAttributes.groupID : @"group_id",
             MessageAttributes.readURL : @"read_url",
             MessageAttributes.replyToMessageID : @"replying_to_message_id",
             MessageAttributes.messageID : @"message_id",
             MessageAttributes.thumbnailPictureURL : @"thumbnail_url",
             MessageAttributes.timeStamp : @"timestamp",
             MessageAttributes.startRecording : @"start_recording",
             MessageAttributes.threadIndex : @"thread_index",
             MessageAttributes.viewedState : @"viewed_state",
             MessageAttributes.downloadState : @"download_state",
             MessageRelationships.recipient : @"recipient_id",
             MessageRelationships.sender : @"sender_id",
             MessageRelationships.thread : @"thread_id",
             
             };
}


@end
