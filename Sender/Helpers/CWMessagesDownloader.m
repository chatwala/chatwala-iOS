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
        
        NSURL *localURL = [NSURL URLWithString:[[CWVideoFileCache sharedCache] filepathForKey:message.messageID]];
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
        
        [CWServerAPI downloadMessageFromReadURL:currentMessage.readURL destinationURLBlock:[self downloadURLDestinationBlock] completionBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            completedRequests++;
            
            if (!error) {
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

+ (NSString *)messageEndpointFromSMSDownloadID:(NSString *)downloadID {
    
    NSArray *downloadIDComponents = [downloadID componentsSeparatedByString:@"."];

    if (2 == [downloadIDComponents count]) {
        NSString *endpoint = [[CWGroundControlManager sharedInstance] messageEndpointWithShardID:[downloadIDComponents objectAtIndex:0]];
        
        // Append the message ID to the URL
        return [endpoint stringByAppendingString:[downloadIDComponents objectAtIndex:1]];
    }
    else {
        return nil;
    }
    
}

#pragma mark - Download methods

- (void)downloadMessageFromEndpoint:(NSString *)endpoint completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock {

    [CWServerAPI downloadMessageFromReadURL:endpoint destinationURLBlock:[self downloadURLDestinationBlock] completionBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if(error) {
            NSLog(@"Error while downloading message file: %@", error);
            if (completionBlock) {
                completionBlock(NO,filePath);//if we need to pass error/response adjust function callback
            }
        }
        else {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: {
                    // success
                    NSLog(@"File downloaded to: %@", filePath);
                    
                    if (completionBlock) {
                        completionBlock(YES,filePath);
                    }
                    
                    break;
                }
                default:
                    // fail
                    NSLog(@"Failed to download message file. with code:%i",httpResponse.statusCode);
                    if (completionBlock) {
                        completionBlock(NO,nil);
                    }
                    break;
            }
        }
    }];
}

#pragma mark - Helper code blocks

- (CWServerAPIDownloadDestinationBlock)downloadURLDestinationBlock {
    
    return (^NSURL *(NSURL *targetPath, NSURLResponse *response){
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[CWVideoFileCache baseCacheDirectoryFilepath]];
        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    });
}

@end
