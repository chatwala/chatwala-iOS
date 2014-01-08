//
//  AOCoreDataStackUtilities.h
//  AOCoreData
//
//  Created by Travis Britt on 5/31/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

/*!
 AOCoreDataStackUtilities provides useful methods for managing the creation and management of Core Data stacks.
 */
@interface AOCoreDataStackUtilities : NSManagedObject


/*!
 Adds a store to the store coordinatpr. This method works asynchronously. The completion handler block will be called once the stack is ready for use. This is useful when running on iOS 6 or lower since this can require some disk I/O, and in the case of iCloud, network access which may block the main thread.
 
 @param storeLocation The NSURL pointing to the store file.
 @param storeCoordinator The NSPersistentStoreCoordinator for the stack.
 @param storeType The type of file store (SQLite, XML, etc.)
 @param configuration The configuration passed to NSPersistentStoreCoordinator -addPersistentStoreWithType
 @param options The options dictionary passed to NSPersistentStoreCoordinator -addPersistentStoreWithType
 @param completionHandler Called once the stack is ready to use.
 */
+ (void)addPersistentStoreWithLocation:(NSURL *)storeLocation andPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator andStoreType:(NSString *)storeType andConfiguration:(NSString *)configuration andOptions:(NSDictionary *)options andCompletionHandler:(void (^)(NSError *))completionHandler;

/*!
 Sets up a Core Data stack with some reasonable defaults. Runs asynchronously, block will be called with managed object context when stoack is ready. Assumes the store is SQLite and is named the same as the model.
 
 @param modelName The name of the model. The name of the store should be the same.
 @param concurrencyType Concurrency type of the managed object context. Either NSMainQueueConcurrencyType or NSPrivateQueueConcurrencyType.
 @param completionHandler Called once the stack is ready to use.
 */
+ (void)createCoreDataStackWithModelName:(NSString *)modelName andConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType andCompletionHandler:(void (^)(NSManagedObjectContext *, NSError *))completionHandler;


//more options
+ (void)createCoreDataStackWithModelName:(NSString *)modelName andConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType options:(NSDictionary *) options andCompletionHandler:(void (^)(NSManagedObjectContext * moc, NSError *error, NSURL * storeURL))completionHandler;

@end
