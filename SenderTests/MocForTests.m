//
//  MocForTests.m
//  AhaLife
//
//  Created by RANDALL LI on 4/16/13.
//  Copyright (c) 2013 AhaLife. All rights reserved.
//

#import "MocForTests.h"
#import <CoreData/CoreData.h>

@implementation MocForTests

- (id)initWithPath:(NSString *) filePath
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:filePath withExtension:@"momd"];
    return [self initWithURL:modelURL];
}

- (id)initWithURL:(NSURL *) url
{
    self = [super init];
    if (self) {
        self.moc = [self inMemoryManagedObjectContextWithURL:url withConcurrencyType:NSMainQueueConcurrencyType];
        self.backgroundMoc = [self inMemoryManagedObjectContextWithURL:url withConcurrencyType:NSPrivateQueueConcurrencyType];
    }
    return self;
}

- (NSManagedObjectContext *) inMemoryManagedObjectContextWithURL:(NSURL *) urlForManagedObjectModel withConcurrencyType:(NSManagedObjectContextConcurrencyType) concurrencyType
{
    NSPersistentStoreCoordinator * persistentStoreCoordinator = [self inMemoryCoordinatorWithURL:urlForManagedObjectModel];
    NSManagedObjectContext * managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    return managedObjectContext;
}

- (NSPersistentStoreCoordinator *) inMemoryCoordinatorWithURL:(NSURL *) urlForManagedObjectModel
{

    NSManagedObjectModel * managedObjectModel = [self managedObjectModelWithURL: urlForManagedObjectModel];

    NSError *error = nil;
    NSPersistentStoreCoordinator * persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return  persistentStoreCoordinator;
}

- (NSManagedObjectModel *) managedObjectModelWithURL:(NSURL *) url
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
}



@end
