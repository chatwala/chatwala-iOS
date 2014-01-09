//
//  MocForTests.h
//  AhaLife
//
//  Created by RANDALL LI on 4/16/13.
//  Copyright (c) 2013 AhaLife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MocForTests : NSObject

@property (nonatomic) NSManagedObjectContext * moc;
@property (nonatomic) NSManagedObjectContext * backgroundMoc;

- (id)initWithPath:(NSString *) filePath;
- (id)initWithURL:(NSURL *) url;


@end
