//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


#import "CWMessageItem.h"

typedef void (^CWMessageManagerFetchMessageUploadIDCompletionBlock)(NSString *messageID, NSString *messageURL);
typedef void (^CWMessageManagerFetchMessageUploadURLCompletionBlock)(NSString *messageID, NSString *uploadURLString);

typedef void (^AFRequestOperationManagerSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFRequestOperationManagerFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

typedef NSURL * (^AFDownloadTaskDestinationBlock) (NSURL *targetPath, NSURLResponse *response);


typedef void (^CWMessageDownloadCompletionBlock)(BOOL success, NSURL *url);
typedef void (^CWDownloadTaskCompletionBlock) (NSURLResponse *response, NSURL *filePath, NSError *error, CWMessageDownloadCompletionBlock messageDownloadCompletionBlock );


@interface CWMessageManager : NSObject < UITableViewDataSource>
@property (nonatomic,readonly) NSString * baseEndPoint;
@property (nonatomic,readonly) NSString * messagesEndPoint;
@property (nonatomic,readonly) NSString * registerEndPoint;
@property (nonatomic,readonly) NSString * getUserMessagesEndPoint;
@property (nonatomic,readonly) NSString * getMessageEndPoint;
@property (nonatomic,readonly) NSString * putUserProfileEndPoint;

//@property (nonatomic,strong) NSArray * messages;

+(instancetype) sharedInstance;
- (void)getMessagesForUser:(User *) user withCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock;
- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(CWMessageDownloadCompletionBlock)completionBlock;

// There are about to be removed
- (void)fetchOriginalMessageIDWithSender:(User *) localUser completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock;

- (void)fetchMessageIDForReplyToMessage:(CWMessageItem *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock;

// Replaced with
- (void)fetchUploadDetailsWithCompletionBlock:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock;

- (void)uploadMessage:(CWMessageItem *)messageToUpload isReply:(BOOL)isReplyMessage;


#pragma mark - callbacks for test

@property (strong, readonly) AFRequestOperationManagerSuccessBlock getMessagesSuccessBlock;
@property (strong, readonly) AFRequestOperationManagerFailureBlock getMessagesFailureBlock;
@property (strong, readonly) AFDownloadTaskDestinationBlock downloadURLDestinationBlock;
@property (strong, readonly) CWDownloadTaskCompletionBlock downloadTaskCompletionBlock;

@end
