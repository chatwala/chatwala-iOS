//
//  CWMessageDownloader.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/11/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWMessagesDownloader.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"
#import "CWDataManager.h"
#import "CWServerAPI.h"
#import "CWVideoFileCache.h"
#import "CWGroundControlManager.h"

@implementation CWMessagesDownloader

- (void)downloadMessages:(NSArray *)messagesToDownload withCompletionBlock:(CWMessagesDownloaderCompletionBlock)completionBlock {

    NSMutableArray *messagesNeedingDownload = [NSMutableArray array];
    
    for (Message *message in messagesToDownload) {
        
        NSURL *localURL = [Message chatwalaZipURL:message.messageID];
        if (!localURL) {
            [messagesNeedingDownload addObject:message];
        }
        else {
            [message setEMessageDownloadState:eMessageDownloadStateDownloaded];
        }
    }
    
    NSInteger totalMessagesToDownload = 0;
    totalMessagesToDownload = [messagesNeedingDownload count];
    
    if (!totalMessagesToDownload) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    
    NSMutableArray *downloadedMessages = [NSMutableArray array];
    
    for (Message *currentMessage in messagesNeedingDownload) {
        
        __block NSInteger completedRequests = 0;
        
        [CWServerAPI downloadMessageFromReadURL:currentMessage.readURL destinationURLBlock:[self downloadURLDestinationBlockForMessageID:currentMessage.messageID] completionBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            completedRequests++;
            
            if (!error) {
                NSLog(@"Downloaded file for messageID: %@", currentMessage.messageID);
                [currentMessage setEMessageDownloadState:eMessageDownloadStateDownloaded];
                [downloadedMessages addObject:currentMessage];
            }
            else {
                NSLog(@"Error: failed download for message from URL:  %@", currentMessage.readURL);
            }
            
            if (totalMessagesToDownload == completedRequests) {
                // All requests completed (failed/succeeded) - let's finish up.
                if (completionBlock) {
                    completionBlock(downloadedMessages);
                }
            }
        }];
    }
}

#pragma mark - Download methods

- (void)downloadMessageWithShareID:(NSString *)downloadID completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock {
    
    [CWServerAPI getReadURLFromShareID:downloadID completionBlock:^(NSString *readURL, NSString *messageID, NSError *error) {
    
        if (error) {
            NSError *error = [NSError errorWithDomain:@"CWMessagesDownloader" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Unable to download message." forKey:NSLocalizedDescriptionKey]];
            completionBlock(error, nil, nil);
        }
        else {
            
            if (![readURL length]) {
                if (completionBlock) {
                    
                    NSError *error = [NSError errorWithDomain:@"CWMessagesDownloader" code:0 userInfo:[NSDictionary dictionaryWithObject:@"This is not a valid message." forKey:NSLocalizedDescriptionKey]];
                    completionBlock(error,nil, nil);
                }
                
                return;
            }
            else {
                
                // If this video already is downloaded don't re-download!
                [self downloadMessageFromReadURL:readURL forMessageID:messageID completion:completionBlock];
            }
        }
    }];
}

- (void)downloadMessageFromReadURL:(NSString *)endpoint forMessageID:(NSString *)messageID completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock {

    [CWServerAPI downloadMessageFromReadURL:endpoint destinationURLBlock:[self downloadURLDestinationBlockForMessageID:messageID] completionBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if(error) {
            NSLog(@"Error while downloading message file: %@", error);
            if (completionBlock) {
                completionBlock(error,filePath,nil);//if we need to pass error/response adjust function callback
            }
        }
        else {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: {
                    // success
                    NSLog(@"File downloaded to: %@", filePath);
                    
                    if (completionBlock) {
                        completionBlock(nil,filePath, messageID);
                    }
                    
                    break;
                }
                default:
                    // fail
                    NSLog(@"Failed to download message file. with code:%li",(long)httpResponse.statusCode);
                    if (completionBlock) {
                        NSError *error = [NSError errorWithDomain:@"CWMessagesDownloader" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Message still downloading." forKey:NSLocalizedDescriptionKey]];
                        completionBlock(error,nil, nil);
                    }
                    break;
            }
        }
    }];
}

#pragma mark - Helper code blocks

- (CWServerAPIDownloadDestinationBlock)downloadURLDestinationBlockForMessageID:(NSString *)messageID {
    
    return (^NSURL *(NSURL *targetPath, NSURLResponse *response){
        NSURL *inboxDirectoryPath = [NSURL fileURLWithPath:[[CWVideoFileCache sharedCache] inboxFilepathForKey:messageID]];
        return [inboxDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    });
}

@end