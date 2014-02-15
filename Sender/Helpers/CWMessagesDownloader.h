//
//  CWMessageDownloader.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/11/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

typedef void (^CWMessageDownloaderCompletionBlock)(NSArray *messagesDownloaded);

@interface CWMessagesDownloader : NSObject

@property (nonatomic, strong) NSArray *messageIdsForDownload;

- (void)startWithCompletionBlock:(CWMessageDownloaderCompletionBlock)completionBlock;
+ (NSString *)filePathForMessageID:(NSString *)messageID;

@end
