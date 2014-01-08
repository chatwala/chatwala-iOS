//
//  AOQueueManager.h
//  AOFoundation
//
//  Created by Kevin Wolkober on 7/31/13.
//  Copyright (c) 2013 iOS Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AOQueueManager : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *pendingOperations;

- (id)initWithMaxOperationCount:(NSInteger)count;

- (void)addOperation:(NSOperation *)operation;
- (void)addOperation:(NSOperation *)operation forKey:(id)key;
- (NSOperation *)operationForKey:(id)key;
- (void)setQueuePriority:(NSOperationQueuePriority)priority forKeys:(NSSet *)keys;
- (void)setQueuePriority:(NSOperationQueuePriority)priority forKey:(id)key;
- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)cancelAllOperations;

@end
