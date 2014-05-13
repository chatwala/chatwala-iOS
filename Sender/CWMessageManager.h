//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "Message.h"

typedef void (^CWMessageManagerFetchMessageUploadURLCompletionBlock)(Message *message, NSString *uploadURLString);

typedef void (^AFRequestOperationManagerSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFRequestOperationManagerFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);


typedef void (^CWMessageDownloadCompletionBlock)(BOOL success, NSURL *url);


@interface CWMessageManager : NSObject
@property (nonatomic,readonly) NSString * baseEndPoint;
@property (nonatomic,readonly) NSString * messagesEndPoint;
@property (nonatomic,readonly) NSString * registerEndPoint;
@property (nonatomic,readonly) NSString * getInboxEndPoint;
@property (nonatomic,readonly) NSString * getMessageEndPoint;


//@property (nonatomic,strong) NSArray * messages;

+(instancetype) sharedInstance;
- (void)getMessagesForUser:(NSString *)userID withCompletionOrNil:(void (^)(UIBackgroundFetchResult))completionBlock;

- (void)fetchUploadURLForOriginalMessage:(NSString *)userID completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock;
- (void)clearUploadURLForOriginalMessage;

- (void)fetchUploadURLForReplyMessage:(Message *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock;
- (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString isReply:(BOOL)isReplyMessage;

- (void)clearDiskSpace;

#pragma mark - callbacks for test

@property (strong, readonly) AFRequestOperationManagerSuccessBlock getMessagesSuccessBlock;
@property (strong, readonly) AFRequestOperationManagerFailureBlock getMessagesFailureBlock;

@end
