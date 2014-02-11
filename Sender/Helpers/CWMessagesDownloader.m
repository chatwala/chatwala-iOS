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

typedef void (^CWMessageDownloaderMessageDownloadCompletionBlock)(BOOL success, NSURL *url);

@implementation CWMessagesDownloader

- (void)startWithCompletionBlock:(CWMessageDownloaderCompletionBlock)completionBlock {

    NSMutableArray *messageIDsNeedingDownload = [NSMutableArray array];
    
    for (NSString *messageID in self.messageIdsForDownload) {
        
        if (![self isMessageDownloadedForMessageID:messageID]) {
            [messageIDsNeedingDownload addObject:messageID];
        }
    }
    
    NSInteger totalMessagesToDownload = 0;
    totalMessagesToDownload = [messageIDsNeedingDownload count];
    
    NSMutableArray *downloadedMessages = [NSMutableArray array];
    
    for (NSString *messageIdToDownload in messageIDsNeedingDownload) {
        [self downloadMessageWithID:messageIdToDownload progress:nil completion:^(BOOL success, NSURL *url) {

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

- (BOOL)isMessageDownloadedForMessageID:(NSString *)messageID {
    // check if file exists locally
    NSString * localPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[messageID stringByAppendingString:@".zip"]];
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        // don't download
        return YES;
    }
    else {
        return NO;
    }
}

- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(CWMessageDownloaderMessageDownloadCompletionBlock)completionBlock
{
    // do download
    NSString * messagePath =[NSString stringWithFormat:[[CWMessageManager alloc] getMessageEndPoint], messageID];
    NSLog(@"downloading file at: %@",messagePath);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:messagePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:request];
    
    
    // EMPTYPUSH:  We need background transfers here right?
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:self.downloadURLDestinationBlock completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        self.messageFileDownloadCompletionBlock(response,filePath,error,completionBlock);
    }];
    
    
    [downloadTask resume];
}

#pragma mark - Helper code blocks

- (AFDownloadTaskDestinationBlock)downloadURLDestinationBlock {
    
    return (^NSURL *(NSURL *targetPath, NSURLResponse *response){
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
    });
}

- (CWDownloadTaskCompletionBlock)messageFileDownloadCompletionBlock {
    
    return (^ void(NSURLResponse *response, NSURL *filePath, NSError *error, CWMessageDownloaderMessageDownloadCompletionBlock  messageDownloadCompletionBlock){
        
        if(error) {
            NSLog(@"error %@", error);
            if (messageDownloadCompletionBlock) {
                messageDownloadCompletionBlock(NO,filePath);//if we need to pass error/response adjust function callback
            }
        }
        else {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 200: {
                    // success
                    NSLog(@"File downloaded to: %@", filePath);
                    NSError * error = nil;
                    
                    NSAssert(!error, @"not expecting an error, found:%@",error);
                    if (messageDownloadCompletionBlock) {
                        messageDownloadCompletionBlock(YES,filePath);
                    }
                    
                    break;
                }
                default:
                    // fail
                    NSLog(@"failed to load message file. with code:%i",httpResponse.statusCode);
                    if (messageDownloadCompletionBlock) {
                        messageDownloadCompletionBlock(NO,nil);
                    }
                    break;
            }
        }
    });
}

@end
