//
//  AOFetchUtilities.h
//  AOCoreData
//
//  Created by Travis Britt on 5/30/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

@class Message;

#import <CoreData/CoreData.h>

/*!
 AOFetchUtilities provides useful methods for fetching in Core Data.
 */
@interface AOFetchUtilities : NSManagedObject

/*!
 Fetches and returns all the objects for this class. Objects will be in the passed managed object context.
 
 @param context The managed object context the objects will be fetched into.
 @param entityName The name of the entity being fetched.
 @param error Contains an NSError if the operation fails.
 @return the fetched managed objects
 */
+(NSArray *)fetchAllObjectsWithContext:(NSManagedObjectContext *)context andEntityName:(NSString *)entityName error:(NSError **)error;

/*!
 Fetches and returns all the objects for this class. Objects will be sorted based on passed array of NSSortDescriptors. Objects will be in the passed managed object context.
 
 @param context The managed object context the objects will be fetched into.
 @param entityName The name of the entity being fetched.
 @param sortDescriptors NSArray of NSSortDescriptors used to sort the fetched objects.
 @param error Contains an NSError if the operation fails.
 @return the fetched managed objects
 */
+(NSArray *)fetchAllObjectsWithContext:(NSManagedObjectContext *)context andEntityName:(NSString *)entityName andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error;

/*!
 Fetches and returns all the objects for this class, limited by the passed in fetchLimit. Objects will be sorted based on passed array of NSSortDescriptors. Objects will be in the passed managed object context.
 
 @param context The managed object context the objects will be fetched into.
 @param entityName The name of the entity being fetched.
 @param sortDescriptors NSArray of NSSortDescriptors used to sort the fetched objects.
 @param fetchLimit NSUInteger limiting the max number of objects fetched.
 @param error Contains an NSError if the operation fails.
 @return the fetched managed objects
 */
+(NSArray *)fetchAllObjectsWithContext:(NSManagedObjectContext *)context andEntityName:(NSString *)entityName andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error;


@end
