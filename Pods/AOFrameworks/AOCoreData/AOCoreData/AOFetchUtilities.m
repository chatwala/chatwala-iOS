//
//  AOFetchUtilities.m
//  AOCoreData
//
//  Created by Travis Britt on 5/30/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

#import "AOFetchUtilities.h"

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


@end
