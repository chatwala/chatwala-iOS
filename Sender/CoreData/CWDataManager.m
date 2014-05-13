//
//  CWDataManager.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWDataManager.h"
#import "AOCoreDataStackUtilities.h"
#import "Message.h"
#import "NSDictionary+LookUpTable.h"
#import "CWUserManager.h"
#import "CWVideoFileCache.h"

@implementation CWDataManager
+ (id)sharedInstance {

    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - find functions

- (Message *) findMessageByMessageID:(NSString*) messageID {
    
    Message * item = (Message *)[self findObject:[Message class] byAttribute:MessageAttributes.messageID withValue:messageID];
    if(item)
    {
        NSAssert([item isKindOfClass:[Message class]], @"expecting to get a Message object. found :%@", item);
    }
    return item;
}

- (AOManagedObject *) findObject:(Class) aClass byAttribute:(NSString *) attribute withValue:(NSString*) value
{
    NSString * format = [NSString stringWithFormat:@"%@ == %%@", attribute];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format,  value];
    NSArray * results = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:predicate];
    [request setEntity:[NSEntityDescription entityForName:[aClass entityName] inManagedObjectContext:self.moc]];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    results = [self.moc executeFetchRequest:request error:&error];
    
    NSAssert(!error, @"expecting no error:%@",error);
    NSAssert(results.count <= 1, @"should only have one or less object: %@", results);
    AOManagedObject * item = [results lastObject];
    return item;
    
}

#pragma mark - import data

- (Message *)createMessageWithSender:(NSString *)senderID inResponseToIncomingMessage:(Message *) incomingMessage videoURL:(NSURL *)videoURL {
    
    Message *message = [Message insertInManagedObjectContext:self.moc];
    message.senderID = senderID;
    message.messageID = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    if(incomingMessage) {
        message.recipientID = incomingMessage.senderID;
        message.threadID = incomingMessage.threadID;
        message.replyToMessageID = incomingMessage.messageID;
        message.groupID = incomingMessage.groupID;
        message.threadIndexValue = incomingMessage.threadIndexValue + 1;
    }
    else {
        message.threadID = [[[NSUUID UUID] UUIDString] lowercaseString];
    }
    
    return message;
}


- (Message *)createMessageWithDictionary:(NSDictionary *) sourceDictionary error:(NSError **)error {

    if(![sourceDictionary isKindOfClass:[NSDictionary class]]) {
        *error = [NSError errorWithDomain:@"com.chatwala" code:6003 userInfo:@{@"Failed import":@"import messages expects an array of dictionaries", @"found":sourceDictionary}];//failed to import
        return nil;
    }
    
    NSString * messageID = [sourceDictionary objectForKey:MessageAttributes.messageID withLUT:[Message keyLookupTable]];
    Message * item = [self findMessageByMessageID:messageID];
    if(!item) {
        item = [Message insertInManagedObjectContext:self.moc];
    }
    
    //add start recording
    NSNumber *startRecording = [sourceDictionary objectForKey:@"start_recording" withLUT:[Message keyLookupTable]];
    
    if (!startRecording) {
        item.startRecording = [NSNumber numberWithInt:0];
    }
    else {
        item.startRecording = startRecording;
    }
    
    [item fromDictionary:sourceDictionary withDateFormatter:[CWDataManager dateFormatter] error:error] ;
    error = nil;
    
    return item;
}

// importMessageAtFilePath used in one places: opener view (sms links & notifications)
- (Message *) importMessage:(NSString *)messageID chatwalaZipURL:(NSURL *)zipURL withError:(NSError **)error {

    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:zipURL.path]) {
        NSLog(@"zip not found at path: %@", zipURL.path);
        return [NSError errorWithDomain:@"com.chatwala" code:6004 userInfo:@{@"reason":@"zip not found at path", @"path": zipURL}];
    }
    
    NSString *importFilepath = [zipURL.path stringByDeletingLastPathComponent];
    
    NSURL *videoLocation = [NSURL fileURLWithPath:[importFilepath stringByAppendingPathComponent:@"video.mp4"]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:videoLocation.path]) {
        [SSZipArchive unzipFileAtPath:zipURL.path toDestination:[zipURL URLByDeletingLastPathComponent].path];
    }
    
    //NSString *metaDataFilename = [item.messageID stringByAppendingString:@".json"];
    NSString *metadataFilePath = [importFilepath stringByAppendingPathComponent:METADATA_FILE_NAME];

    Message * item = nil;
    if ([fm fileExistsAtPath:importFilepath]) {
        if ([fm fileExistsAtPath:metadataFilePath isDirectory:NO]) {
            NSDictionary * baseDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:metadataFilePath] options:0 error:nil];
            NSMutableDictionary *jsonDict = [baseDictionary mutableCopy];
            
            // This is a check for "<null>" threadID value because of a 1.0.5 iOS bug
            NSString *threadIDValue = [jsonDict objectForKey:@"thread_id"];
            
            if ([threadIDValue isEqual:[NSNull null]] || !threadIDValue) {
                NSLog(@"Thread ID null works");
                [jsonDict setValue:[[[NSUUID UUID] UUIDString] lowercaseString] forKey:@"thread_id"];
            }
            
            
            if (![jsonDict count]) {
                NSLog(@"failed to parse json metdata: %@",(*error).debugDescription);
                return nil;
            }
            
            item = [self createMessageWithDictionary:jsonDict error:error];
            if(*error)
            {
                return nil;
            }
            
            [item setEMessageDownloadState:eMessageDownloadStateDownloaded];
            NSError *newError = nil;
            if(newError)
            {
                return nil;
            }
        }
        else {
            *error = [NSError errorWithDomain:@"chatwala.com"
                                         code:6006
                                     userInfo:@{
                                                @"reason":@"could not find json file",
                                                @"file":metadataFilePath}];
            NSLog(@"could not find json file at %@",metadataFilePath);
            return nil;
        }
    }
    return item;
}

#pragma mark - dateformater

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

#pragma mark - Core Data stack

- (void)setupCoreData {

    [AOCoreDataStackUtilities createCoreDataStackWithModelName:@"ChatwalaModel"
                                            andConcurrencyType:NSMainQueueConcurrencyType
                                                       options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption: @YES}
                                          andCompletionHandler:^(NSManagedObjectContext *moc, NSError *error, NSURL *storeURL) {
     
        self.moc = moc;
        
        if(error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            //lets move a the save file to see if we can fix this by erasing the save file
            NSURL * newURL = [[storeURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i", [storeURL lastPathComponent], arc4random_uniform(NSUIntegerMax)]];
            NSLog(@"copy core data store to %@", newURL);
            NSError * error = nil;
            [[NSFileManager defaultManager] moveItemAtURL:storeURL toURL:newURL error:&error];

        }
    }];
    
}

@end
