//
//  AOManagedObject.m
//  AOCoreData
//
//  Created by Travis Britt on 5/20/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AOManagedObject.h"
#import "NSDictionary+LookUpTable.h"

@implementation AOManagedObjectID : NSManagedObjectID
@end

@implementation AOManagedObject

#pragma mark - JSON transformer Methods

/* 
 Transforms a string JSON value into the proper object type based on the passed NSAttributeType. The NSDateFormatter is used to transform any date string for attribute types of NSDateAttributeType.
 */
-(id)_safeObjectFromJsonValue:(id)value forAttributeType:(NSAttributeType)attributeType andDateFormatter:(NSDateFormatter *)dateFormatter
{
    id safeValue = value;
    
    if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]]))
    {
        safeValue = [value stringValue];
    }
    else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]]))
    {
        safeValue = [NSNumber numberWithInteger:[value integerValue]];
    }
    else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]]))
    {
        safeValue = [NSNumber numberWithDouble:[value doubleValue]];
    }
    else if (attributeType == NSDateAttributeType)
    {
        if([value isKindOfClass:[NSNumber class]])
        {
            safeValue = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
        }
        else
        {
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            NSNumber * number = [numberFormatter numberFromString: value];
            if ([number isKindOfClass:[NSNumber class]])
            {
                //the string value is actually a number so treat it as such
                safeValue = [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
            }
            else
            {
                safeValue = [dateFormatter dateFromString:value];
            }
        }
        NSDate * now = [NSDate date];
        if([safeValue isEqual:[now laterDate:safeValue]])
        {
            //assumes that the time came in at milliseconds
            NSDate * dateAfterSecondsConversion = [NSDate dateWithTimeIntervalSince1970:[safeValue timeIntervalSince1970]/1000];
            if([dateAfterSecondsConversion isEqual:[now earlierDate:dateAfterSecondsConversion]])
            {
                safeValue = dateAfterSecondsConversion;
            }
            else
            {
                safeValue = nil;
            }
            
        }
    }
    
    return safeValue;
}

-(AOManagedObject *)fromJSON:(NSData *)json withDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error
{
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:error];
    return [self fromDictionary:jsonDict withDateFormatter:dateFormatter error:error];
}

-(AOManagedObject *)fromDictionary:(NSDictionary *)dictionary withDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error
{
    NSDictionary *attributes = [[self entity] attributesByName];
    
    for (NSString *attribute in attributes) {
        id value = [dictionary objectForKey:attribute withLUT:[self.class keyLookupTable]];
        
        if (value == nil) {
            continue;
        }
        
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        value = [self _safeObjectFromJsonValue:value forAttributeType:attributeType andDateFormatter:dateFormatter];
        [self setValue:value forKey:attribute];
    }
    
    return self;
}

- (NSDictionary *) toDictionaryWithDataFormatter:(NSDateFormatter *) dateFormatter error:(NSError **) error
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSDictionary *attributes = [[self entity] attributesByName];
    
    for (NSString *attribute in attributes) {
        id value = [self valueForKey:attribute];
        
        if (value == nil) {
            value = [NSNull null];
            continue;
        }
        
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        
        if (attributeType == NSDateAttributeType) {
            NSDate *date = (NSDate *)[attributes objectForKey:attribute];
            
            NSTimeInterval timeInterval = [date timeIntervalSince1970] * 1000;
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeInterval];
            value = intervalString;
        }
//        if (attributeType == NSDateAttributeType)
//        {
//            if(dateFormatter != nil)
//            {
//                value = [dateFormatter stringFromDate:value];
//            }
//            else
//            {
//                NSTimeInterval timeSinceEpoch = [value timeIntervalSince1970];
//                value = [NSString stringWithFormat:@"%lli",(long long)(timeSinceEpoch * 1000)];
//                //                value = [NSNumber numberWithLongLong:(timeSinceEpoch * 1000)];//if the value needs to be a number instead of a string
//            }
//        }
        
        [jsonDict setValue:value forKey:attribute];
    }
    return jsonDict;
}

-(NSData *)toJSONWithDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error
{
    NSDictionary * jsonDict = [self toDictionaryWithDataFormatter:dateFormatter error:error];
    
    NSData *jsonObj = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:error];
    
    return jsonObj;
}

+ (NSDictionary *) keyLookupTable
{
    return @{};
}



@end
