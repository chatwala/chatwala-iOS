// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.h instead.

#import <CoreData/CoreData.h>
#import "AOFetchUtilities.h"
#import "AOManagedObject.h"


@class User;
@class User;
@class Thread;


@protocol _Message <NSObject>
    



@property (nonatomic, strong) NSNumber* downloadState;




@property (atomic) int16_t downloadStateValue;







@property (nonatomic, strong) NSString* groupID;








@property (nonatomic, strong) NSString* messageID;








@property (nonatomic, strong) NSString* messageURL;








@property (nonatomic, strong) NSString* readURL;








@property (nonatomic, strong) NSString* replyToMessageID;








@property (nonatomic, strong) NSNumber* startRecording;




@property (atomic) double startRecordingValue;







@property (nonatomic, strong) NSString* storageShardKey;








@property (nonatomic, strong) NSNumber* threadIndex;




@property (atomic) int32_t threadIndexValue;







@property (nonatomic, strong) NSString* thumbnailPictureURL;








@property (nonatomic, strong) NSDate* timeStamp;








@property (nonatomic, strong) NSNumber* viewedState;




@property (atomic) int16_t viewedStateValue;








@property (nonatomic, strong) User *recipient;





@property (nonatomic, strong) User *sender;





@property (nonatomic, strong) Thread *thread;




@end


extern const struct MessageAttributes {
	__unsafe_unretained NSString *downloadState;
	__unsafe_unretained NSString *groupID;
	__unsafe_unretained NSString *messageID;
	__unsafe_unretained NSString *messageURL;
	__unsafe_unretained NSString *readURL;
	__unsafe_unretained NSString *replyToMessageID;
	__unsafe_unretained NSString *startRecording;
	__unsafe_unretained NSString *storageShardKey;
	__unsafe_unretained NSString *threadIndex;
	__unsafe_unretained NSString *thumbnailPictureURL;
	__unsafe_unretained NSString *timeStamp;
	__unsafe_unretained NSString *viewedState;
} MessageAttributes;



extern const struct MessageRelationships {
	__unsafe_unretained NSString *recipient;
	__unsafe_unretained NSString *sender;
	__unsafe_unretained NSString *thread;
} MessageRelationships;





extern const struct MessageUserInfo {
} MessageUserInfo;




























@interface MessageID : AOManagedObjectID {}
@end

@interface _Message : AOManagedObject <_Message> {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSArray *)fetchAllMessagesWithContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSArray *)fetchAllMessagesWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors error:(NSError **)error;
+ (NSArray *)fetchAllMessagesWithContext:(NSManagedObjectContext *)context andSortDescriptors:(NSArray *)sortDescriptors andFetchLimit:(NSUInteger)fetchLimit error:(NSError **)error;
- (MessageID*)objectID;





@property (nonatomic, strong) NSNumber* downloadState;




@property (atomic) int16_t downloadStateValue;
- (int16_t)downloadStateValue;
- (void)setDownloadStateValue:(int16_t)value_;







@property (nonatomic, strong) NSString* groupID;








@property (nonatomic, strong) NSString* messageID;








@property (nonatomic, strong) NSString* messageURL;








@property (nonatomic, strong) NSString* readURL;








@property (nonatomic, strong) NSString* replyToMessageID;








@property (nonatomic, strong) NSNumber* startRecording;




@property (atomic) double startRecordingValue;
- (double)startRecordingValue;
- (void)setStartRecordingValue:(double)value_;







@property (nonatomic, strong) NSString* storageShardKey;








@property (nonatomic, strong) NSNumber* threadIndex;




@property (atomic) int32_t threadIndexValue;
- (int32_t)threadIndexValue;
- (void)setThreadIndexValue:(int32_t)value_;







@property (nonatomic, strong) NSString* thumbnailPictureURL;








@property (nonatomic, strong) NSDate* timeStamp;








@property (nonatomic, strong) NSNumber* viewedState;




@property (atomic) int16_t viewedStateValue;
- (int16_t)viewedStateValue;
- (void)setViewedStateValue:(int16_t)value_;







@property (nonatomic, strong) User *recipient;





@property (nonatomic, strong) User *sender;





@property (nonatomic, strong) Thread *thread;






@end



@interface _Message (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveDownloadState;
- (void)setPrimitiveDownloadState:(NSNumber*)value;

- (int16_t)primitiveDownloadStateValue;
- (void)setPrimitiveDownloadStateValue:(int16_t)value_;




- (NSString*)primitiveGroupID;
- (void)setPrimitiveGroupID:(NSString*)value;




- (NSString*)primitiveMessageID;
- (void)setPrimitiveMessageID:(NSString*)value;




- (NSString*)primitiveMessageURL;
- (void)setPrimitiveMessageURL:(NSString*)value;




- (NSString*)primitiveReadURL;
- (void)setPrimitiveReadURL:(NSString*)value;




- (NSString*)primitiveReplyToMessageID;
- (void)setPrimitiveReplyToMessageID:(NSString*)value;




- (NSNumber*)primitiveStartRecording;
- (void)setPrimitiveStartRecording:(NSNumber*)value;

- (double)primitiveStartRecordingValue;
- (void)setPrimitiveStartRecordingValue:(double)value_;




- (NSString*)primitiveStorageShardKey;
- (void)setPrimitiveStorageShardKey:(NSString*)value;




- (NSNumber*)primitiveThreadIndex;
- (void)setPrimitiveThreadIndex:(NSNumber*)value;

- (int32_t)primitiveThreadIndexValue;
- (void)setPrimitiveThreadIndexValue:(int32_t)value_;




- (NSString*)primitiveThumbnailPictureURL;
- (void)setPrimitiveThumbnailPictureURL:(NSString*)value;




- (NSDate*)primitiveTimeStamp;
- (void)setPrimitiveTimeStamp:(NSDate*)value;




- (NSNumber*)primitiveViewedState;
- (void)setPrimitiveViewedState:(NSNumber*)value;

- (int16_t)primitiveViewedStateValue;
- (void)setPrimitiveViewedStateValue:(int16_t)value_;





- (User*)primitiveRecipient;
- (void)setPrimitiveRecipient:(User*)value;



- (User*)primitiveSender;
- (void)setPrimitiveSender:(User*)value;



- (Thread*)primitiveThread;
- (void)setPrimitiveThread:(Thread*)value;


@end
