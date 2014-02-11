//
//  CWDataManager.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWDataManager.h"
#import "AOCoreDataStackUtilities.h"
#import "Message.h"
#import "NSDictionary+LookUpTable.h"
#import "CWUserManager.h"
#import "CWMessagesDownloader.h"

@implementation CWDataManager
+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - find functions


- (Thread *) findThreadByThreadID:(NSString*) threadID
{
    Thread * item = (Thread *)[self findObject:[Thread class] byAttribute:ThreadAttributes.threadID withValue:threadID];
    if(item)
    {
        NSAssert([item isKindOfClass:[Thread class]], @"expecting to get a Thread object. found :%@", item);
    }
    return item;
}

- (Message *) findMessageByMessageID:(NSString*) messageID
{
    Message * item = (Message *)[self findObject:[Message class] byAttribute:MessageAttributes.messageID withValue:messageID];
    if(item)
    {
        NSAssert([item isKindOfClass:[Message class]], @"expecting to get a Message object. found :%@", item);
    }
    return item;
}

- (User *) findUserByUserID:(NSString *) userID
{
    User * item = (User *)[self findObject:[User class] byAttribute:UserAttributes.userID withValue:userID];
    if(item)
    {
        NSAssert([item isKindOfClass:[User class]], @"expecting to get a User object. found :%@", item);
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

- (Thread *) createThreadWithID:(NSString *) threadID
{
    if(nil == threadID)
    {
        return nil;
    }
    Thread * thread = [self findThreadByThreadID:threadID];
    if(!thread)
    {
        thread = [Thread insertInManagedObjectContext:self.moc];
        thread.threadID = threadID;
    }
    return thread;
}

- (User *) createUserWithID:(NSString *) userID
{
    if(nil == userID)
    {
        return nil;
    }
    User * user = [self findUserByUserID:userID];
    if(!user)
    {
        user = [User insertInManagedObjectContext:self.moc];
        user.userID = userID;
    }
    return user;
}

- (Message *) createMessageWithSender:(User *) sender inResponseToIncomingMessage:(Message *) incomingMessage
{
    Message * message = [Message insertInManagedObjectContext:self.moc];
    message.sender = sender;
    message.timeStamp = [NSDate date];
    message.messageID = [[NSUUID UUID] UUIDString];;
    
    if(incomingMessage)
    {
        message.recipient = incomingMessage.sender;
        message.thread = incomingMessage.thread;
        message.threadIndexValue = incomingMessage.threadIndexValue + 1;
    }
    else
    {
        message.thread = [self createThreadWithID:[[NSUUID UUID] UUIDString]];
    }
    return message;
}


- (Message *)createMessageWithDictionary:(NSDictionary *) sourceDictionary error:(NSError **)error
{
    if(![sourceDictionary isKindOfClass:[NSDictionary class]])
    {
        *error = [NSError errorWithDomain:@"com.chatwala" code:6003 userInfo:@{@"Failed import":@"import messages expects an array of dictionaries", @"found":sourceDictionary}];//failed to import
        return nil;
    }
    NSString * messageID = [sourceDictionary objectForKey:MessageAttributes.messageID withLUT:[Message keyLookupTable]];
    Message * item = [self findMessageByMessageID:messageID];
    if(!item)
    {
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
    
    //add users
    NSString * senderID = [sourceDictionary objectForKey:MessageRelationships.sender withLUT:[Message keyLookupTable]];
    User * sender = [self createUserWithID:senderID];
    [item setSender:sender];
    
    NSString * receiverID = [sourceDictionary objectForKey:MessageRelationships.recipient withLUT:[Message keyLookupTable]];
    item.recipient = [self createUserWithID:receiverID];
    
    //add thread
    NSString * threadID = [sourceDictionary objectForKey:MessageRelationships.thread withLUT:[Message keyLookupTable]];
    item.thread = [self createThreadWithID:threadID];
    

    
    return item;
}

// importMessageAtFilePath used in two places:  opener view (sms links & now notifications) and when walas are downloaded from the inbox.
// Ideally we want SMS links to be added to the inbox & let the same flow handle the unpackaging of the data. [RK - 02112014]

- (Message *) importMessageAtFilePath:(NSURL *) filePath withError:(NSError **)error
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:filePath.path]) {
        NSLog(@"zip not found at path: %@",filePath.path);
        return [NSError errorWithDomain:@"com.chatwala" code:6004 userInfo:@{@"reason":@"zip not found at path", @"path":filePath}];
    }
    NSString * destPath = [[CWDataManager cacheDirectoryPath] stringByAppendingPathComponent:INCOMING_DIRECTORY_NAME];
    [SSZipArchive unzipFileAtPath:filePath.path toDestination:destPath];
    
    NSString * metadataFileName = [destPath stringByAppendingPathComponent:METADATA_FILE_NAME];

    Message * item = nil;
    if ([fm fileExistsAtPath:destPath]) {
        if ([fm fileExistsAtPath:metadataFileName isDirectory:NO]) {
            NSDictionary * baseDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:metadataFileName] options:0 error:error];
            NSMutableDictionary *jsonDict = [baseDictionary mutableCopy];
            
            // This is a check for "<null>" threadID value because of a 1.0.5 iOS bug
            NSString *threadIDValue = [jsonDict objectForKey:@"thread_id"];
            
            if ([threadIDValue isEqual:[NSNull null]] && [threadIDValue isEqual:[NSNull null]]) {
                NSLog(@"Thread ID null works");
                [jsonDict setValue:[[NSUUID UUID] UUIDString] forKey:@"thread_id"];
            }
            
            
            if (*error) {
                NSLog(@"failed to parse json metdata: %@",(*error).debugDescription);
                return nil;
            }
            
            item = [self createMessageWithDictionary:jsonDict error:error];
            if(*error)
            {
                return nil;
            }
            
            [item setEMessageDownloadState:eMessageDownloadStateDownloaded];
            [item.managedObjectContext save:error];
            if(*error)
            {
                return nil;
            }
        }
        else
        {
            *error = [NSError errorWithDomain:@"chatwala.com"
                                         code:6006
                                     userInfo:@{
                                                @"reason":@"could not find json file",
                                                @"file":metadataFileName}];
            NSLog(@"could not find json file at %@",metadataFileName);
            return nil;
        }
        
        
        // set video url
        [item setVideoURL:[NSURL fileURLWithPath:[destPath stringByAppendingPathComponent:VIDEO_FILE_NAME]]];
    }
    return item;
}

+ (NSString*)cacheDirectoryPath {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

#pragma mark - dateformater

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

#pragma mark - Core Data stack

- (void) setupCoreData
{

    [AOCoreDataStackUtilities createCoreDataStackWithModelName:@"ChatwalaModel" andConcurrencyType:NSMainQueueConcurrencyType options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} andCompletionHandler:^(NSManagedObjectContext *moc, NSError *error, NSURL *storeURL) {
     
        self.moc = moc;
        
        if(error)
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            //lets move a the save file to see if we can fix this by erasing the save file
            NSURL * newURL = [[storeURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i", [storeURL lastPathComponent], arc4random_uniform(NSUIntegerMax)]];
            NSLog(@"copy core data store to %@", newURL);
            NSError * error = nil;
            [[NSFileManager defaultManager] moveItemAtURL:storeURL toURL:newURL error:&error];
            NSAssert(!error, @"error: %@ backing up save file: %@", error, storeURL);
            
            abort();

        }
    }];
    
}

@end
