//
//  NSDictionary+LookUpTable.h
//  AhaLife
//
//  Created by randall AhaLife on 6/28/13.
//  Copyright (c) 2013 AhaLife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LookUpTable)
- (id) objectForKey:(NSString *)key withLUT:(NSDictionary *) lut;

+ (NSDictionary *) dictionaryByReassignKeysOfDictionary:(NSDictionary *) sourceDictionary withKeys:(NSDictionary *) lutForKeys;

@end
