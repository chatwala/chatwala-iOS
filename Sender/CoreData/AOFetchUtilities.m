//
//  AOFetchUtilities.m
//  AOCoreData
//
//  Created by Travis Britt on 5/30/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

#import "AOFetchUtilities.h"
#import "CWDataManager.h"
#import "CWUserManager.h"

@implementation AOFetchUtilities

+ (NSArray *)fetchAllObjectsWithContext:(NSManagedObjectContext *)context andEntityName:(NSString *)entityName error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:entityName andSortDescriptors:nil andFetchLimit:0 error:error];
}

+ (NSArray *)fetchAllObjectsWithContext:(NSManagedObjectContext *)context andEntityName:(NSString *)entityName andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:entityName andSortDescriptors:sortDescriptors andFetchLimit:0 error:error];
}

+ (NSArray *)fetchAllObjectsWithContext:(NSManagedObjectContext *)context andEntityName:(NSString *)entityName andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error
{
    NSArray *fetchedObjects = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchLimit:fetchLimit];
    fetchedObjects = [context executeFetchRequest:fetchRequest error:error];
    
    return fetchedObjects;
}

+ (void)markAllMessagesAsReadForUser:(NSString *)userID {
    
    NSArray *messagesArray = [AOFetchUtilities unreadMessagesForUser:userID];
    
    for (Message *message in messagesArray) {
        [message setEMessageViewedState:eMessageViewedStateRead];
    }
}

+ (void)markAllMessagesAsDeviceDeletedForUser:(NSString *)userID {
    NSArray *messagesArray = [AOFetchUtilities messagesForUser:userID];
    
    for (Message *message in messagesArray) {
        [message setEMessageDownloadState:eMessageDownloadStateDeviceDeleted];
    }
}

+ (NSArray *)fetchGroupBySenderID {

    NSManagedObjectContext *managedObjectContext = [[CWDataManager sharedInstance] moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"timeStamp"]; // Does not really matter
    NSExpression *maxExpression = [NSExpression expressionForFunction: @"max:"
                                                            arguments: [NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    [expressionDescription setName: @"maxTimestamp"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSDateAttributeType];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"senderID", @"recipientID", expressionDescription, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"senderID", @"recipientID", nil]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // Sort the results by the most recent message
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:[results count]];

    // Return an array of array of Message objects for the UI to show
    for (NSDictionary *currentSenderDictionary in results) {
        
        NSString *recipientID = [currentSenderDictionary objectForKey:@"recipientID"];
        
        if ([recipientID isEqualToString:[[CWUserManager sharedInstance] localUserID]]) {
            NSArray *userMessages = [AOFetchUtilities fetchMessagesForSender:[currentSenderDictionary objectForKey:@"senderID"]];
            
            if ([userMessages count]) {
                [filteredArray addObject:userMessages];
            }
        }
    }
    
    return filteredArray;
}

+ (NSArray *)fetchMessagesForSender:(NSString *)senderID {
    
    NSManagedObjectContext *moc = [[CWDataManager sharedInstance] moc];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(senderID == %@)", senderID];
    [request setPredicate:predicate];
    
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
    
    NSError *error = nil;
    NSArray *messagesArray = [moc executeFetchRequest:request error:&error];
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:[messagesArray count]];
    
    for (Message *message in messagesArray) {
        if ([message.downloadState integerValue] == eMessageDownloadStateDownloaded || [message.downloadState integerValue] == eMessageDownloadStateDeviceDeleted) {
            
            // Don't show messages previously deleted but not successfully deleted on server yet
            if ([message isMarkedAsDeleted]) {
                [message deleteMessageFromInbox];
            }
            else {
                [filteredArray addObject:message];
            }
        }
    }
    
    if (filteredArray) {
        return filteredArray;
    }
    else {
        return nil;
    }
}

+ (NSArray *)unreadMessagesForUser:(NSString *)userID {
    NSManagedObjectContext *moc = [[CWDataManager sharedInstance] moc];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(recipientID == %@ && viewedState == 0 && (downloadState == 2 || downloadState == 3))", userID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *messagesArray = [moc executeFetchRequest:request error:&error];
    
    return messagesArray;
}

+ (NSArray *)messagesForUser:(NSString *)userID {
    NSManagedObjectContext *moc = [[CWDataManager sharedInstance] moc];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(recipientID == %@)", userID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *messagesArray = [moc executeFetchRequest:request error:&error];
    
    return messagesArray;
}

+ (NSInteger)totalUnreadMessagesForRecipient:(NSString *)userID {
    return [[AOFetchUtilities unreadMessagesForUser:userID] count];
}

+ (Message *)messageWithThreadID:(NSString *)threadID withThreadIndex:(NSInteger)threadIndex {
    
    NSManagedObjectContext *moc = [[CWDataManager sharedInstance] moc];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(threadID == %@ && threadIndex == %ld)", threadID, (long)threadIndex];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *messagesArray = [moc executeFetchRequest:request error:&error];
    
    return ([messagesArray count] ? [messagesArray objectAtIndex:0] : nil);
}

@end
