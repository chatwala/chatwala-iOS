//
//  CWMessageDownloader.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/11/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

typedef void (^CWMessagesDownloaderCompletionBlock)(NSArray *messagesDownloaded);
typedef void (^CWMessagesDownloaderSingleMessageDownloadCompletionBlock)(BOOL success, NSURL *url);

@interface CWMessagesDownloader : NSObject



- (void)downloadMessages:(NSArray *)messageIDsForDownload withCompletionBlock:(CWMessagesDownloaderCompletionBlock)completionBlock;

// Single message download
- (void)downloadMessageWithID:(NSString *)downloadIdentifier completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock;

@end
