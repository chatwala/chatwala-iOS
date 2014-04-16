#import "Message.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"
#import "NSDictionary+LookUpTable.h"
#import "CWServerAPI.h"
#import "CWConstants.h"
#import "CWUserManager.h"

@interface Message ()

@end

@implementation Message
@synthesize videoURL;
@synthesize zipURL;
@synthesize lastFrameImage;
@synthesize thumbnailUploadURLString;

// Custom logic goes here.

+ (NSDictionary *) keyLookupTable {

    return @{
             @"user_thumbnail_url" : MessageAttributes.userThumbnailURL,
             @"recipient_id" : MessageAttributes.recipientID,
             @"sender_id"   : MessageAttributes.senderID,
             @"thread_id"   : MessageAttributes.threadID,
             @"group_id" : MessageAttributes.groupID,
             @"replying_to_message_id" : MessageAttributes.replyToMessageID,
             @"thread_index" : MessageAttributes.threadIndex,
             @"message_id" : MessageAttributes.messageID,
             @"thumbnail_url" : MessageAttributes.thumbnailPictureURL,
             @"timestamp" : MessageAttributes.timeStamp,
             @"start_recording" : MessageAttributes.startRecording,
             @"share_url" :  MessageAttributes.messageURL,
             @"read_url"  : MessageAttributes.readURL,
             @"blob_storage_shard_key" : MessageAttributes.storageShardKey
             };
}

- (void)saveContext {

    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
#if defined USE_DEV_SERVER  || defined USE_QA_SERVER
            abort();
#endif
        } 
    }
}

#pragma mark - Adding/removing message from inbox

- (void)addMessageToUserInbox:(NSString *)userID {
    
    if ([userID length] && [self.recipientID isEqualToString:CWConstantsUnknownRecipientIDString]) {
        NSLog(@"Adding message to inbox...");
        [CWServerAPI addMessage:self.messageID toInboxForUser:userID];
    }
}

- (void)deleteMessageFromInbox {
    
    NSLog(@"Deleting message from inbox...");
    [self.managedObjectContext deleteObject:self];
    [CWServerAPI deleteMessage:self.messageID fromInboxForUser:[[CWUserManager sharedInstance] localUserID]];
    [self setIsMarkedAsDeleted:YES];
}

- (BOOL)isMarkedAsDeleted {
    
    // Using the message
    NSString *defaultsKey = [NSString stringWithFormat:@"%@-%@", CWConstantsMessageMarkedDeletedKey, self.messageID];
    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultsKey];
}

- (void)setIsMarkedAsDeleted:(BOOL)deleted {
    NSString *defaultsKey = [NSString stringWithFormat:@"%@-%@", CWConstantsMessageMarkedDeletedKey, self.messageID];
    
    [[NSUserDefaults standardUserDefaults] setBool:deleted forKey:defaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Message State

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
    }
    
    [self saveContext];
}


- (eMessageDownloadState) eDownloadState {
    NSInteger value = self.downloadStateValue;
    NSAssert(value < eMessageDownloadStateTotal, @"expecting download state to be less than max enum value");
    NSAssert(value >= eMessageDownloadStateInvalid, @"expecting download state to be less than max enum value");
    return (eMessageDownloadState)value;
}

- (void)setEMessageDownloadState:(eMessageDownloadState)eState {
    self.downloadStateValue = eState;
    [self saveContext];
}

- (void)uploadThumbnailImage:(UIImage *)image {
    
    // Kick off a CWServerAPI thumbnail request
    [CWServerAPI uploadMessageThumbnail:image toURL:self.thumbnailUploadURLString withCompletionBlock:nil];
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
             MessageAttributes.senderID,
             MessageAttributes.recipientID,
             MessageAttributes.threadID,
             MessageAttributes.groupID,
             MessageAttributes.readURL,
             MessageAttributes.replyToMessageID,
             MessageAttributes.messageURL,
             MessageAttributes.messageID,
             MessageAttributes.threadIndex,
             MessageAttributes.startRecording,
             MessageAttributes.timeStamp,
             MessageAttributes.thumbnailPictureURL,
             MessageAttributes.storageShardKey,
             MessageAttributes.userThumbnailURL,
             ];
}

+ (NSDictionary *) reverseKeyLookupTable
{
    return @{
             MessageAttributes.userThumbnailURL : @"user_thumbnail_url",
             MessageAttributes.threadID : @"thread_id",
             MessageAttributes.recipientID : @"recipient_id",
             MessageAttributes.senderID : @"sender_id",
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
             MessageAttributes.storageShardKey : @"blob_storage_shard_key"
             };
}

@end