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


+ (NSArray *)fetchExample {
    
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
    
    
    NSExpression *messageKeyPathExpression = [NSExpression expressionForKeyPath: @"messageID"];
    NSExpression *countExpression = [NSExpression expressionForFunction: @"count:"
                                                            arguments: [NSArray arrayWithObject:messageKeyPathExpression]];
    
    NSExpressionDescription *countDescription = [[NSExpressionDescription alloc] init];
    
    [countDescription setName: @"countMessages"];
    [countDescription setExpression:countExpression];
    [countDescription setExpressionResultType:NSInteger32AttributeType];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"senderID", expressionDescription, countDescription, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"senderID",nil]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderID!=%@", [[CWUserManager sharedInstance] localUserID] ];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setResultType:NSDictionaryResultType];
    NSError* error = nil;
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest
                                                           error:&error];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"maxTimestamp"
                                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [results sortedArrayUsingDescriptors:sortDescriptors];
        
    return sortedArray;
}

@end
