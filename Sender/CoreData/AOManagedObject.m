//
//  AOManagedObject.m
//  AOCoreData
//
//  Created by Travis Britt on 5/20/13.
//  Copyright (c) 2013 AppOrchard, LLC. All rights reserved.
//

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
    else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) && (dateFormatter != nil))
    {
        safeValue = [dateFormatter dateFromString:value];
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

-(NSData *)toJSONWithDateFormatter:(NSDateFormatter *)dateFormatter error:(NSError **)error
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    NSDictionary *attributes = [[self entity] attributesByName];
    
    for (NSString *attribute in attributes) {
        id value = [self valueForKey:attribute];
        
        if (value == nil) {
            value = [NSNull null];
        }
        
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        
        if ((attributeType == NSDateAttributeType) && (dateFormatter != nil)) {
            value = [dateFormatter stringFromDate:value];
        }
        
        [jsonDict setValue:value forKey:attribute];
    }
    
    NSData *jsonObj = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:error];
    
    return jsonObj;
}

+ (NSDictionary *) keyLookupTable
{
    return @{};
}



@end
