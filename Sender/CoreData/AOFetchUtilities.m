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
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"senderID", expressionDescription, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"senderID",nil]];
    
    // Remove our own user from the sender list...
    [fetchRequest setResultType:NSDictionaryResultType];
    
    // Sort the results by the most recent message
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:[results count]];
    
    for (NSDictionary *currentSenderDictionary in results) {
        
        NSArray *userMessages = [AOFetchUtilities fetchMessagesForUser:[currentSenderDictionary objectForKey:@"senderID"]];
        
        if ([userMessages count]) {
            [filteredArray addObject:currentSenderDictionary];
        }
    }
    
    return filteredArray;
}

+ (NSArray *)fetchMessagesForUser:(NSString *)userID {
    
    NSManagedObjectContext *moc = [[CWDataManager sharedInstance] moc];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Message" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(senderID == %@)", userID];
    [request setPredicate:predicate];
    
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
    
    NSError *error = nil;
    NSArray *messagesArray = [moc executeFetchRequest:request error:&error];
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:[messagesArray count]];
    
    // Only show downloaded messages
    for (Message *message in messagesArray) {
        if ([message.downloadState integerValue] == eMessageDownloadStateDownloaded && [message.recipientID isEqualToString:[[CWUserManager sharedInstance] localUserID]]) {
            [filteredArray addObject:message];
        }
    }
    
    if (filteredArray) {
        return filteredArray;
    }
    else {
        return nil;
    }
}

@end
