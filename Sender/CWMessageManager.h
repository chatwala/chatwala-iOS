//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadCompletionBlock)(BOOL success, NSURL *url);


@interface CWMessageManager : NSObject < UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,readonly) NSString * baseEndPoint;
@property (nonatomic,readonly) NSString * messagesEndPoint;
@property (nonatomic,readonly) NSString * registerEndPoint;
@property (nonatomic,readonly) NSString * getUserMessagesEndPoint;
@property (nonatomic,readonly) NSString * getMessageEndPoint;
@property (nonatomic,readonly) NSString * putUserProfileEndPoint;

@property (nonatomic,strong) NSArray * messages;
+(instancetype) sharedInstance;
- (void)getMessages;
- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(DownloadCompletionBlock)completionBlock;

@end
