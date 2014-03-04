//
//  CWAPICommandFactory.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/4/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

@class CWAPICommand;

@interface CWAPICommandFactory : NSObject

+ (CWAPICommand *)commandWithcompletionBlockOrNil:(void (^)())completionBlock;

@end
