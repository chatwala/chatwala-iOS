//
//  CWAPICommandFactory.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/4/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

@class CWCommand;

@interface CWAPICommandFactory : NSObject

+ (CWCommand *)commandWithcompletionBlockOrNil:(void (^)())completionBlock;

@end
