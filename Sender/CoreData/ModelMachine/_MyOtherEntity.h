// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MyOtherEntity.h instead.

#import <CoreData/CoreData.h>
#import "AOFetchUtilities.h"
#import "AOManagedObject.h"




@protocol _MyOtherEntity <NSObject>
    



@end








extern const struct MyOtherEntityUserInfo {
} MyOtherEntityUserInfo;




@interface MyOtherEntityID : AOManagedObjectID {}
@end

@interface _MyOtherEntity : AOManagedObject <_MyOtherEntity> {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSArray *)fetchAllMyOtherEntitysWithContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSArray *)fetchAllMyOtherEntitysWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error;
+ (NSArray *)fetchAllMyOtherEntitysWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error;
- (MyOtherEntityID*)objectID;






@end



@interface _MyOtherEntity (CoreDataGeneratedPrimitiveAccessors)


@end
