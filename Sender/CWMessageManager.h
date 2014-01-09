//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


#import "CWMessageItem.h"

typedef void (^DownloadCompletionBlock)(BOOL success, NSURL *url);
typedef void (^CWMessageManagerFetchMessageUploadIDCompletionBlock)(NSString *messageID, NSString *messageURL);

typedef void (^AFRequestOperationManagerSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFRequestOperationManagerFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

typedef NSURL * (^AFDownloadTaskDestinationBlock) (NSURL *targetPath, NSURLResponse *response);


@interface CWMessageManager : NSObject < UITableViewDataSource>
@property (nonatomic,readonly) NSString * baseEndPoint;
@property (nonatomic,readonly) NSString * messagesEndPoint;
@property (nonatomic,readonly) NSString * registerEndPoint;
@property (nonatomic,readonly) NSString * getUserMessagesEndPoint;
@property (nonatomic,readonly) NSString * getMessageEndPoint;
@property (nonatomic,readonly) NSString * putUserProfileEndPoint;

@property (nonatomic,strong) NSArray * messages;

+(instancetype) sharedInstance;
- (void)getMessagesWithCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock;
- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(DownloadCompletionBlock)completionBlock;
- (void)fetchOriginalMessageIDWithCompletionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock;
- (void)fetchMessageIDForReplyToMessage:(CWMessageItem *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock;
- (void)uploadMessage:(CWMessageItem *)messageToUpload isReply:(BOOL)isReplyMessage;

@property (strong, readonly) AFRequestOperationManagerSuccessBlock getMessagesSuccessBlock;
@property (strong, readonly) AFRequestOperationManagerFailureBlock getMessagesFailureBlock;
@property (strong, readonly) AFDownloadTaskDestinationBlock downloadDestinationBlock;

@end
