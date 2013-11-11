//
//  TestUtils.h
//  Sender
//
//  Created by Khalid on 11/11/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>

@interface TestUtils : NSObject
+ (void)waitForVerifiedMock:(OCMockObject *)mock delay:(NSTimeInterval)delay;
@end
