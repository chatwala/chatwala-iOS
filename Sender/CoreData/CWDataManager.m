//
//  CWDataManager.m
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWDataManager.h"
#import <AOFrameworks/AOCoreDataStackUtilities.h>
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

#pragma mark - import data

- (NSError *) importMessages:(NSArray *)messages
{
    if(![messages isKindOfClass:[NSArray class]])
    {
        return [NSError errorWithDomain:@"com.chatwala" code:6002 userInfo:@{@"Failed import":@"import messages expects an array", @"found":messages}];//failed to import
    }
    
    NSError * error = nil;
    for (NSDictionary * messageDictionary in messages) {
        if(![messageDictionary isKindOfClass:[NSDictionary class]])
        {
            return [NSError errorWithDomain:@"com.chatwala" code:6003 userInfo:@{@"Failed import":@"import messages expects an array of dictionaries", @"found":messageDictionary}];//failed to import
        }
        Message * item = [Message insertInManagedObjectContext:self.moc];
        
        [item fromDictionary:messageDictionary withDateFormatter:nil error:&error];
        
        if(error)
        {
            return error;
        }
    }
    
    [self.moc save:&error];
    
    
    return error;
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
