//
//  AOCoreDataStackUtilities.m
//  AOCoreData
//
//  Created by Travis Britt on 5/31/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

#import "AOCoreDataStackUtilities.h"

@implementation AOCoreDataStackUtilities


+ (void)addPersistentStoreWithLocation:(NSURL *)storeLocation andPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator andStoreType:(NSString *)storeType andConfiguration:(NSString *)configuration andOptions:(NSDictionary *)options andCompletionHandler:(void (^)(NSError *))completionHandler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        [storeCoordinator addPersistentStoreWithType:storeType
                                  configuration:configuration
                                            URL:storeLocation
                                        options:options
                                          error:&error];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            completionHandler(error);
        });
    });
}

+ (void)createCoreDataStackWithModelName:(NSString *)modelName andConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType andCompletionHandler:(void (^)(NSManagedObjectContext *, NSError *))completionHandler
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    NSManagedObjectModel *mom = nil;
    mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = nil;
    psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSManagedObjectContext *moc = nil;
    moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *storeURL = [directoryArray lastObject];
    NSString *storeName = [modelName stringByAppendingString:@".sqlite"];
    storeURL = [storeURL URLByAppendingPathComponent:storeName];
    
    [AOCoreDataStackUtilities addPersistentStoreWithLocation:storeURL andPersistentStoreCoordinator:psc andStoreType:NSSQLiteStoreType andConfiguration:nil andOptions:nil andCompletionHandler:^(NSError *error) {
        
        completionHandler(moc, error);
    }];
}

+ (void)createCoreDataStackWithModelName:(NSString *)modelName andConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType options:(NSDictionary *) options andCompletionHandler:(void (^)(NSManagedObjectContext * moc, NSError *error, NSURL * storeURL))completionHandler
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    NSManagedObjectModel *mom = nil;
    mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSPersistentStoreCoordinator *psc = nil;
    psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSManagedObjectContext *moc = nil;
    moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *directoryArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *storeURL = [directoryArray lastObject];
    NSString *storeName = [modelName stringByAppendingString:@".sqlite"];
    storeURL = [storeURL URLByAppendingPathComponent:storeName];
    
    [AOCoreDataStackUtilities addPersistentStoreWithLocation:storeURL andPersistentStoreCoordinator:psc andStoreType:NSSQLiteStoreType andConfiguration:nil andOptions:options andCompletionHandler:^(NSError *error) {
        
        completionHandler(moc, error, storeURL);
    }];
}

@end
