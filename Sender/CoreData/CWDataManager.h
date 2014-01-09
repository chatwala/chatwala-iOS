//
//  CWDataManager.h
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface CWDataManager : NSObject
+ (id)sharedInstance;

@property (nonatomic, strong) User * localUser;
@property (nonatomic, strong) NSManagedObjectContext * moc;

- (void) setupCoreData;
- (NSError *) importMessages:(NSArray *) messages;

@end
