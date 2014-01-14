// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "AOFetchUtilities.h"
#import "AOManagedObject.h"


@class Message;
@class Message;


@protocol _User <NSObject>
    



@property (nonatomic, strong) NSString* profilePictureURL;








@property (nonatomic, strong) NSString* userID;









@property (nonatomic, strong) NSOrderedSet *messagesReceived;





@property (nonatomic, strong) NSSet *messagesSent;




@end


extern const struct UserAttributes {
	__unsafe_unretained NSString *profilePictureURL;
	__unsafe_unretained NSString *userID;
} UserAttributes;



extern const struct UserRelationships {
	__unsafe_unretained NSString *messagesReceived;
	__unsafe_unretained NSString *messagesSent;
} UserRelationships;





extern const struct UserUserInfo {
} UserUserInfo;








@interface UserID : AOManagedObjectID {}
@end

@interface _User : AOManagedObject <_User> {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSArray *)fetchAllUsersWithContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSArray *)fetchAllUsersWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error;
+ (NSArray *)fetchAllUsersWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* profilePictureURL;








@property (nonatomic, strong) NSString* userID;








@property (nonatomic, strong) NSOrderedSet *messagesReceived;

- (NSMutableOrderedSet*)messagesReceivedSet;




@property (nonatomic, strong) NSSet *messagesSent;

- (NSMutableSet*)messagesSentSet;





@end


@interface _User (MessagesReceivedCoreDataGeneratedAccessors)
- (void)addMessagesReceived:(NSOrderedSet*)value_;
- (void)removeMessagesReceived:(NSOrderedSet*)value_;
- (void)addMessagesReceivedObject:(Message*)value_;
- (void)removeMessagesReceivedObject:(Message*)value_;
@end

@interface _User (MessagesSentCoreDataGeneratedAccessors)
- (void)addMessagesSent:(NSSet*)value_;
- (void)removeMessagesSent:(NSSet*)value_;
- (void)addMessagesSentObject:(Message*)value_;
- (void)removeMessagesSentObject:(Message*)value_;
@end


@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveProfilePictureURL;
- (void)setPrimitiveProfilePictureURL:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;





- (NSMutableOrderedSet*)primitiveMessagesReceived;
- (void)setPrimitiveMessagesReceived:(NSMutableOrderedSet*)value;



- (NSMutableSet*)primitiveMessagesSent;
- (void)setPrimitiveMessagesSent:(NSMutableSet*)value;


@end
