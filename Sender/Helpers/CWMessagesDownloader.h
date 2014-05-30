//
//  CWMessageDownloader.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/11/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

typedef void (^CWMessagesDownloaderCompletionBlock)(NSArray *messagesDownloaded);
typedef void (^CWMessagesDownloaderSingleMessageDownloadCompletionBlock)(NSError *error, NSURL *url, NSString *messageID);

@interface CWMessagesDownloader : NSObject

- (void)downloadMessages:(NSArray *)messageIDsForDownload withCompletionBlock:(CWMessagesDownloaderCompletionBlock)completionBlock;

// Single message download
- (void)downloadMessageWithShareID:(NSString *)downloadID completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock;
- (void)downloadMessageFromReadURL:(NSString *)endpoint forMessageID:(NSString *)messageID toSentbox:(BOOL)toSentBox completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock;

@end
