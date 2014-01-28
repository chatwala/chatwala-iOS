//
//  NSDictionary+LookUpTable.m
//  AhaLife
//
//  Created by randall AhaLife on 6/28/13.
//  Copyright (c) 2013 AhaLife. All rights reserved.
//

#import "NSDictionary+LookUpTable.h"

@implementation NSDictionary (LookUpTable)
- (id) objectForKey:(NSString *)key withLUT:(NSDictionary *) lut
{
    id value = [self objectForKey:key];
    if (value == nil)
    {
        //try looking via the look up table
        NSArray * keys = [lut allKeysForObject:key];
        for (NSString * lutKey in keys) {
            value = [self objectForKey:lutKey];
            if(value)
            {
                break;
            }
        }
    }
    return value;
}

@end
