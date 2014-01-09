// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.m instead.

#import "_Message.h"


const struct MessageAttributes MessageAttributes = {
	.downloadState = @"downloadState",
	.messageID = @"messageID",
	.startRecording = @"startRecording",
	.threadIndex = @"threadIndex",
	.thumbnailPictureURL = @"thumbnailPictureURL",
	.timeStamp = @"timeStamp",
	.viewedState = @"viewedState",
};



const struct MessageRelationships MessageRelationships = {
	.recipient = @"recipient",
	.sender = @"sender",
	.thread = @"thread",
};





const struct MessageUserInfo MessageUserInfo = {
};


@implementation MessageID
@end

@implementation _Message

+ (NSArray *)fetchAllMessagesWithContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"Message" error:error];
}

+ (NSArray *)fetchAllMessagesWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"Message" andSortDescriptors:sortDescriptors error:error];
}

+ (NSArray *)fetchAllMessagesWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error
{
    return [AOFetchUtilities fetchAllObjectsWithContext:context andEntityName:@"Message" andSortDescriptors:sortDescriptors andFetchLimit:fetchLimit error:error];
}

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (MessageID*)objectID {
	return (MessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"downloadStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloadState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"messageIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"messageID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startRecordingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startRecording"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"threadIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"threadIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewedStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewedState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic downloadState;



- (int16_t)downloadStateValue {
	NSNumber *result = [self downloadState];
	return [result shortValue];
}


- (void)setDownloadStateValue:(int16_t)value_ {
	[self setDownloadState:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveDownloadStateValue {
	NSNumber *result = [self primitiveDownloadState];
	return [result shortValue];
}

- (void)setPrimitiveDownloadStateValue:(int16_t)value_ {
	[self setPrimitiveDownloadState:[NSNumber numberWithShort:value_]];
}





@dynamic messageID;



- (double)messageIDValue {
	NSNumber *result = [self messageID];
	return [result doubleValue];
}


- (void)setMessageIDValue:(double)value_ {
	[self setMessageID:[NSNumber numberWithDouble:value_]];
}


- (double)primitiveMessageIDValue {
	NSNumber *result = [self primitiveMessageID];
	return [result doubleValue];
}

- (void)setPrimitiveMessageIDValue:(double)value_ {
	[self setPrimitiveMessageID:[NSNumber numberWithDouble:value_]];
}





@dynamic startRecording;



- (double)startRecordingValue {
	NSNumber *result = [self startRecording];
	return [result doubleValue];
}


- (void)setStartRecordingValue:(double)value_ {
	[self setStartRecording:[NSNumber numberWithDouble:value_]];
}


- (double)primitiveStartRecordingValue {
	NSNumber *result = [self primitiveStartRecording];
	return [result doubleValue];
}

- (void)setPrimitiveStartRecordingValue:(double)value_ {
	[self setPrimitiveStartRecording:[NSNumber numberWithDouble:value_]];
}





@dynamic threadIndex;



- (int32_t)threadIndexValue {
	NSNumber *result = [self threadIndex];
	return [result intValue];
}


- (void)setThreadIndexValue:(int32_t)value_ {
	[self setThreadIndex:[NSNumber numberWithInt:value_]];
}


- (int32_t)primitiveThreadIndexValue {
	NSNumber *result = [self primitiveThreadIndex];
	return [result intValue];
}

- (void)setPrimitiveThreadIndexValue:(int32_t)value_ {
	[self setPrimitiveThreadIndex:[NSNumber numberWithInt:value_]];
}





@dynamic thumbnailPictureURL;






@dynamic timeStamp;






@dynamic viewedState;



- (int16_t)viewedStateValue {
	NSNumber *result = [self viewedState];
	return [result shortValue];
}


- (void)setViewedStateValue:(int16_t)value_ {
	[self setViewedState:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveViewedStateValue {
	NSNumber *result = [self primitiveViewedState];
	return [result shortValue];
}

- (void)setPrimitiveViewedStateValue:(int16_t)value_ {
	[self setPrimitiveViewedState:[NSNumber numberWithShort:value_]];
}





@dynamic recipient;

	

@dynamic sender;

	

@dynamic thread;

	






@end



