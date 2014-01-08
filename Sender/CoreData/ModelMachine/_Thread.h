// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.h instead.

#import <CoreData/CoreData.h>
#import <AOFetchUtilities.h>
#import "AOManagedObject.h"


@class Message;


@protocol _Thread <NSObject>
    



@property (nonatomic, strong) NSString* threadID;









@property (nonatomic, strong) NSOrderedSet *messages;




@end


extern const struct ThreadAttributes {
	__unsafe_unretained NSString *threadID;
} ThreadAttributes;



extern const struct ThreadRelationships {
	__unsafe_unretained NSString *messages;
} ThreadRelationships;





extern const struct ThreadUserInfo {
} ThreadUserInfo;






@interface ThreadID : AOManagedObjectID {}
@end

@interface _Thread : AOManagedObject <_Thread> {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSArray *)fetchAllThreadsWithContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSArray *)fetchAllThreadsWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error;
+ (NSArray *)fetchAllThreadsWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error;
- (ThreadID*)objectID;





@property (nonatomic, strong) NSString* threadID;








@property (nonatomic, strong) NSOrderedSet *messages;

- (NSMutableOrderedSet*)messagesSet;





@end


@interface _Thread (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSOrderedSet*)value_;
- (void)removeMessages:(NSOrderedSet*)value_;
- (void)addMessagesObject:(Message*)value_;
- (void)removeMessagesObject:(Message*)value_;
@end


@interface _Thread (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveThreadID;
- (void)setPrimitiveThreadID:(NSString*)value;





- (NSMutableOrderedSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableOrderedSet*)value;


@end
