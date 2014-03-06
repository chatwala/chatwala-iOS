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

@implementation CWMessagesDownloader

- (void)downloadMessages:(NSArray *)messageIDsForDownload withCompletionBlock:(CWMessagesDownloaderCompletionBlock)completionBlock {

    NSMutableArray *messageIDsNeedingDownload = [NSMutableArray array];
    
    for (NSString *messageID in messageIDsForDownload) {
        
        if (![[[CWVideoFileCache sharedCache] filepathForKey:messageID] length]) {
            [messageIDsNeedingDownload addObject:messageID];
        }
    }
    
    NSInteger totalMessagesToDownload = 0;
    totalMessagesToDownload = [messageIDsNeedingDownload count];
    
    if (!totalMessagesToDownload) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    
    NSMutableArray *downloadedMessages = [NSMutableArray array];
    
    for (NSString *messageIdToDownload in messageIDsNeedingDownload) {
        [self downloadMessageWithID:messageIdToDownload completion:^(BOOL success, NSURL *url) {

            NSInteger completedRequests = 0;
            completedRequests++;
            
            if (success) {
                [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
                
                // TODO: This should happen elsewhere [RK]
                NSError *error = nil;
                Message *newMessage = [[CWDataManager sharedInstance] importMessageAtFilePath:url withError:&error];
                [downloadedMessages addObject:newMessage];
                
            }
            else {
                NSLog(@"Error: failed download for message ID:  %@", messageIdToDownload);
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

- (void)downloadMessageWithID:(NSString *)downloadIdentifier completion:(CWMessagesDownloaderSingleMessageDownloadCompletionBlock)completionBlock {
    
    [CWServerAPI downloadMessageForID:downloadIdentifier destinationURLBlock:[self downloadURLDestinationBlock] completionBlock:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
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