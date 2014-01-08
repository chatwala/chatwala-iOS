//
//  CWDataManager.h
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWDataManager : NSObject
+ (id)sharedInstance;

@property (nonatomic, strong) NSManagedObjectContext * moc;

- (void) setup;

@end
