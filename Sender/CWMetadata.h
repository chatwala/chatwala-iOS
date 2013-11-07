//
//  CWMetadata.h
//  Sender
//
//  Created by Khalid on 11/7/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWMetadata : MTLModel <MTLJSONSerializing>
@property (nonatomic,strong) NSDate * timestamp;
@property (nonatomic,strong) NSString * versionId;
@property (nonatomic,strong) NSString * senderId;
@property (nonatomic,strong) NSString * recipientId;
@property (nonatomic,strong) NSString * messageId;
@property (nonatomic,strong) NSString * threadId;
@property (nonatomic,assign) NSInteger threadIndex;
@property (nonatomic,assign) CGFloat startRecording;
@end
