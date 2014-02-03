#import "Message.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"

@interface Message ()

// Private interface goes here.

@end


@implementation Message
@synthesize videoURL;
@synthesize zipURL;
@synthesize lastFrameImage;

// Custom logic goes here.

+ (NSDictionary *) keyLookupTable
{
    return @{
             @"message_id":@"messageID",
             @"recipient_id":@"recipient",
             @"sender_id":@"sender",
             @"thumbnail":@"thumbnailPictureURL",
             @"timestamp":@"timeStamp",
             @"start_recording":@"startRecording",
             };
}

- (eMessageViewedState) eMessageViewedState
{
    NSInteger value = self.viewedStateValue;
    NSAssert(value < eMessageViewedStateTotal, @"expecting viewed state to be less than max enum value");
    NSAssert(value >= eMessageViewedStateInvalid, @"expecting viewed state to be less than max enum value");
    return value;
    
}
- (void) setEMessageViewedState:(eMessageViewedState) eViewedState
{
    self.viewedStateValue = eViewedState;
}


- (eMessageDownloadState) eDownloadState
{
    NSInteger value = self.downloadStateValue;
    NSAssert(value < eMessageDownloadStateTotal, @"expecting download state to be less than max enum value");
    NSAssert(value >= eMessageDownloadStateInvalid, @"expecting download state to be less than max enum value");
    return value;
}

- (void) setEMessageDownloadState:(eMessageDownloadState ) eState
{
    self.downloadStateValue = eState;
}

- (void) downloadChatwalaDataWithMessageCell:(CWMessageCell *) messageCell
{
    if(messageCell.thumbView)
    {
        NSURL * imageURL = [NSURL URLWithString:self.thumbnailPictureURL];
        
        UIImage *placeholder = [UIImage imageNamed:@"message_thumb"];
        NSMutableURLRequest * imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
        
        [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:imageURLRequest];
        
        [messageCell.thumbView setImageWithURLRequest:imageURLRequest placeholderImage:placeholder success:messageCell.successImageDownloadBlock failure:messageCell.failureImageDownloadBlock];
    }
    
    [[CWMessageManager sharedInstance] downloadMessageWithID:self.messageID progress:nil completion:^(BOOL success, NSURL *url) {
        [[CWUserManager sharedInstance] localUser:^(User *localUser) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[localUser numberOfUnreadMessages]];
        }];
        [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
    }];
    
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
    
    NSLog(@"ready!");
    // zip it up
    NSAssert(self.zipURL, @"expecting zip URL to be set");
    [SSZipArchive createZipFileAtPath:self.zipURL.path withContentsOfDirectory:newDirectoryPath];
}

- (NSDictionary *) toDictionaryWithDataFormatter:(NSDateFormatter *) dateFormatter error:(NSError **) error
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[super toDictionaryWithDataFormatter:dateFormatter error:error]];
    
    
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
    
    return [Message dictionaryByReassignKeysOfDictionary:jsonDict withKeys:[Message reverseKeyLookupTable]];
}

+ (NSDictionary *) dictionaryByReassignKeysOfDictionary:(NSDictionary *) sourceDictionary withKeys:(NSDictionary *) lutForKeys
{
    NSMutableDictionary * destinationDictionary = [NSMutableDictionary dictionaryWithCapacity:sourceDictionary.count];
    for (id key in sourceDictionary.allKeys) {
        id value = [sourceDictionary objectForKey:key];
        id newKey = [lutForKeys objectForKey:key];
        if(newKey)
        {
            [destinationDictionary setObject:value forKey:newKey];
        }
        else
        {
            [destinationDictionary setObject:value forKey:key];
        }
    }
    
    return destinationDictionary;
}

+ (NSDictionary *) reverseKeyLookupTable
{
    return @{
             MessageAttributes.messageID : @"message_id",
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
