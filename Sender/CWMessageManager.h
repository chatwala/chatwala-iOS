//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "Message.h"


typedef void (^CWMessageManagerFetchMessageUploadURLCompletionBlock)(NSString *messageID, NSString *uploadURLString, NSString *downloadURLString);

typedef void (^AFRequestOperationManagerSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFRequestOperationManagerFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);


typedef void (^CWMessageDownloadCompletionBlock)(BOOL success, NSURL *url);


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

- (void)fetchUploadURLForOriginalMessage:(User *)localUser completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock;
- (void)clearUploadURLForOriginalMessage;

- (void)fetchUploadURLForReplyToMessage:(Message *)message completionBlockOrNil:(CWMessageManagerFetchMessageUploadURLCompletionBlock)completionBlock;
- (void)uploadMessage:(Message *)messageToUpload toURL:(NSString *)uploadURLString isReply:(BOOL)isReplyMessage;

#pragma mark - callbacks for test

@property (strong, readonly) AFRequestOperationManagerSuccessBlock getMessagesSuccessBlock;
@property (strong, readonly) AFRequestOperationManagerFailureBlock getMessagesFailureBlock;

@end
