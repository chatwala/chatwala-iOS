//
//  AOQueueManager.m
//  AOFoundation
//
//  Created by Kevin Wolkober on 7/31/13.
//  Copyright (c) 2013 iOS Developer. All rights reserved.
//

#import "AOQueueManager.h"

@implementation AOQueueManager

- (id)init
{
    self = [super init];
    if(self)
    {
        _pendingOperations = [[NSMutableDictionary alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"Operation Queue";
    }
    return self;
}

- (id)initWithMaxOperationCount:(NSInteger)count
{
    self = [self init];
    if (self) {
        _operationQueue.maxConcurrentOperationCount = count;
    }
    return self;
}


#pragma mark - Add / Remove / Retrieve an in-progress operation

- (void)addOperation:(NSOperation *)operation
{
    [self.operationQueue addOperation:operation];
}

- (void)addOperation:(NSOperation *)operation forKey:(id)key
{
    /* Listen for when an operation is finished or cancelled.
       If it is, automatically remove it from the pendingOperations dictionary */
    [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:(__bridge void *)(key)];
    [operation addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:(__bridge void *)(key)];
    [self.pendingOperations setObject:operation forKey:key];
    [self.operationQueue addOperation:operation];
}

/* Get operation reference from pendingOperations dictionary */
- (NSOperation *)operationForKey:(id)key
{
    NSOperation *operation = [self.pendingOperations objectForKey:key];
    return operation;
}


#pragma mark - Set queue priority for an operation(s)

- (void)setQueuePriority:(NSOperationQueuePriority)priority forKeys:(NSSet *)keys
{
    for (id key in keys) {
        [self setQueuePriority:priority forKey:key];
    }
}

- (void)setQueuePriority:(NSOperationQueuePriority)priority forKey:(id)key
{
    id pendingOperation = [self operationForKey:key];
    if (pendingOperation)
        [pendingOperation setQueuePriority:priority];
}


#pragma mark - Suspend / Resume / Cancel all operations

- (void)suspendAllOperations {
    [self.operationQueue setSuspended:YES];
}

- (void)resumeAllOperations {
    [self.operationQueue setSuspended:NO];
}

- (void)cancelAllOperations {
    [self.pendingOperations removeAllObjects];
    [self.operationQueue cancelAllOperations];
}


#pragma mark - Private methods for removing operation references from the pendingOperations dictionary

- (void)removeOperationForKey:(id)key
{
    [self.pendingOperations removeObjectForKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id key = (__bridge id)(context);
    [self removeOperationForKey:key];
}

@end
