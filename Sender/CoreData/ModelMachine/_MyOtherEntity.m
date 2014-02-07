// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MyOtherEntity.m instead.

#import "_MyOtherEntity.h"








const struct MyOtherEntityUserInfo MyOtherEntityUserInfo = {
};


@implementation MyOtherEntityID
@end

@implementation _MyOtherEntity

+ (NSArray *)fetchAllMyOtherEntitysWithContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"MyOtherEntity" error:error];
}

+ (NSArray *)fetchAllMyOtherEntitysWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"MyOtherEntity" andSortDescriptors:sortDescriptors error:error];
}

+ (NSArray *)fetchAllMyOtherEntitysWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"MyOtherEntity" andSortDescriptors:sortDescriptors andFetchLimit:fetchLimit error:error];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MyOtherEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MyOtherEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MyOtherEntity" inManagedObjectContext:moc_];
}

- (MyOtherEntityID*)objectID {
	return (MyOtherEntityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




