//
//  Heap.h
//
//  Created by Ravi Parikh on 4/11/13.
//  Copyright (c) 2013 Heap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Heap : NSObject

@property (nonatomic, copy) NSString* currentViewController;

// creates or retrieves the Heap shared instance
+ (Heap *)sharedInstance;

// sets the user appID
- (void)setAppId:(NSString *) newAppId;

// start debug mode: display Heap activity to NSLog console
- (void)startDebug;

// stop debug mode
- (void)stopDebug;

// equivalent to the heap.identify JS method
// attaches user meta-level properties (e.g. email, handle)
- (void)identify:(NSDictionary *) dict;

// equivalent to the heap.track JS method
// can register a custom event if needed
- (void)track:(NSString *) type withProperties:(NSDictionary *) dict;

// change the frequency at which Heap sends data to heap server
// default is 15.0 seconds
- (void)changeInterval:(double) interval;

@end
