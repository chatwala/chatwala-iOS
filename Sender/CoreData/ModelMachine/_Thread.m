// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.m instead.

#import "_Thread.h"


const struct ThreadAttributes ThreadAttributes = {
	.threadID = @"threadID",
};



const struct ThreadRelationships ThreadRelationships = {
	.messages = @"messages",
};





const struct ThreadUserInfo ThreadUserInfo = {
};


@implementation ThreadID
@end

@implementation _Thread

+ (NSArray *)fetchAllThreadsWithContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"Thread" error:error];
}

+ (NSArray *)fetchAllThreadsWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"Thread" andSortDescriptors:sortDescriptors error:error];
}

+ (NSArray *)fetchAllThreadsWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"Thread" andSortDescriptors:sortDescriptors andFetchLimit:fetchLimit error:error];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Thread";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Thread" inManagedObjectContext:moc_];
}

- (ThreadID*)objectID {
	return (ThreadID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic threadID;






@dynamic messages;

	
- (NSMutableOrderedSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"messages"];
  
	[self didAccessValueForKey:@"messages"];
	return result;
}
	






@end


@implementation _Thread (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSOrderedSet*)value_ {
	[self.messagesSet unionOrderedSet:value_];
}
- (void)removeMessages:(NSOrderedSet*)value_ {
	[self.messagesSet minusOrderedSet:value_];
}
- (void)addMessagesObject:(Message*)value_ {
	[self.messagesSet addObject:value_];
}
- (void)removeMessagesObject:(Message*)value_ {
	[self.messagesSet removeObject:value_];
}
@end



