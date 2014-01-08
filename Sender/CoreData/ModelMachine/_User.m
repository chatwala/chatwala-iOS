// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"


const struct UserAttributes UserAttributes = {
	.profilePictureURL = @"profilePictureURL",
	.userID = @"userID",
};



const struct UserRelationships UserRelationships = {
	.messagesReceived = @"messagesReceived",
	.messagesSent = @"messagesSent",
};





const struct UserUserInfo UserUserInfo = {
};


@implementation UserID
@end

@implementation _User

+ (NSArray *)fetchAllUsersWithContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"User" error:error];
}

+ (NSArray *)fetchAllUsersWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"User" andSortDescriptors:sortDescriptors error:error];
}

+ (NSArray *)fetchAllUsersWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"User" andSortDescriptors:sortDescriptors andFetchLimit:fetchLimit error:error];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic profilePictureURL;






@dynamic userID;






@dynamic messagesReceived;

	

@dynamic messagesSent;

	






@end




