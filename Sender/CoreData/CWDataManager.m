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

@interface CWDataManager ()
{
    
}


@end


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

- (void) createMessageWithDictionary:(NSDictionary *) sourceDictionary error:(NSError **)error
{
    if(![sourceDictionary isKindOfClass:[NSDictionary class]])
    {
        *error = [NSError errorWithDomain:@"com.chatwala" code:6003 userInfo:@{@"Failed import":@"import messages expects an array of dictionaries", @"found":sourceDictionary}];//failed to import
        return;
    }
    NSString * messageID = [sourceDictionary objectForKey:MessageAttributes.messageID];
    Message * item = [self findMessageByMessageID:messageID];
    if(!item)
    {
        item = [Message insertInManagedObjectContext:self.moc];
    }
    
    [item fromDictionary:sourceDictionary withDateFormatter:[CWDataManager dateFormatter] error:error] ;
    
    //add users
    NSString * senderID = [sourceDictionary objectForKey:MessageRelationships.sender];
    item.sender = [self createUserWithID:senderID];
    
    NSString * receiverID = [sourceDictionary objectForKey:MessageRelationships.recipient];
    item.recipient = [self createUserWithID:receiverID];
    
    //add thread
    NSString * threadID = [sourceDictionary objectForKey:MessageRelationships.thread];
    item.thread = [self createThreadWithID:threadID];
}

- (NSError *) importMessages:(NSArray *)messages
{
    if(![messages isKindOfClass:[NSArray class]])
    {
        return [NSError errorWithDomain:@"com.chatwala" code:6002 userInfo:@{@"Failed import":@"import messages expects an array", @"found":messages}];//failed to import
    }
    
    NSError * error = nil;
    for (NSDictionary * messageDictionary in messages) {
        [self createMessageWithDictionary:messageDictionary error:&error];
        if(error)
        {
            return error;
        }
    }
    
    [self.moc save:&error];
    
    
    return error;
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
