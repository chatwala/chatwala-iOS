//
//  AOManagedObject.h
//  AOCoreData
//
//  Created by Travis Britt on 5/20/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface AOManagedObjectID : NSManagedObjectID
@end

/*!
 AOManagedObject provides reusable Core Data code.
 */
@interface AOManagedObject : NSManagedObject


/*!
 Returns a JSON representation of the managed object.
 
 @param dateFormatter An NSDateFormatter used when transforming NSDate objects to a string for JSON. Since there is no standard JSON date representation the caller needs to pass in the date formatter itself. 
 
 @return JSON representation of the managed object
 */
-(NSData *)toJSONWithDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error;


/*!
 Returns the managed object populated with values from a JSON representation.
 
 @param json The JSON to be used to populate the managed object.
 @param dateFormatter An NSDateFormatter used when transforming date string from the JSON to an NSDate. Since there is no standard JSON date representation the caller needs to pass in the date formatter itself.
 
 @return the AOManagedObject with attribute values populated by the passed JSON.
 */
-(AOManagedObject *)fromJSON:(NSData *)json withDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error;

/*!
 Returns the managed object populated with values from a NSDictionary representation.
 
 @param dictionary The NSDictionary to be used to populate the managed object.
 @param dateFormatter An NSDateFormatter used when transforming date string from the JSON to an NSDate. Since there is no standard JSON date representation the caller needs to pass in the date formatter itself.
 
 @return the AOManagedObject with attribute values populated by the passed JSON.
 */
-(AOManagedObject *)fromDictionary:(NSDictionary *)dictionary withDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error;

/*!
 Returns a NSDictionary representation of the managed object.
 
 @param dateFormatter An NSDateFormatter used when transforming NSDate objects to a string for NSDictionary. Since there is no standard String date representation the caller needs to pass in the date formatter itself.
 
 @return JSON representation of the managed object
 */
- (NSDictionary *) toDictionaryWithDataFormatter:(NSDateFormatter *) dateFormatter error:(NSError **) error;

//for when the keys on the sever change
+ (NSDictionary *) keyLookupTable;


@end
