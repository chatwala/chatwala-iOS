//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//


#import "CWMessageItem.h"

typedef void (^DownloadCompletionBlock)(BOOL success, NSURL *url);
typedef void (^CWMessageManagerFetchMessageUploadIDCompletionBlock)(BOOL success);

@interface CWMessageManager : NSObject < UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,readonly) NSString * baseEndPoint;
@property (nonatomic,readonly) NSString * messagesEndPoint;
@property (nonatomic,readonly) NSString * registerEndPoint;
@property (nonatomic,readonly) NSString * getUserMessagesEndPoint;
@property (nonatomic,readonly) NSString * getMessageEndPoint;
@property (nonatomic,strong) NSArray * messages;

// Used for uploading a new message to server
@property (nonatomic,assign,readonly) BOOL needsMessageUploadID;
@property (nonatomic,readonly) NSString *idForNewMessage;
@property (nonatomic,readonly) NSString *urlForNewMessage;

+(instancetype) sharedInstance;

- (void)getMessages;
- (void)downloadMessageWithID:(NSString *)messageID progress:(void (^)(CGFloat progress))progressBlock completion:(DownloadCompletionBlock)completionBlock;
- (void)fetchMessageUploadIDWithCompletionBlockOrNil:(CWMessageManagerFetchMessageUploadIDCompletionBlock)completionBlock;
- (void)uploadMesage:(CWMessageItem *)messageToUpload;

@end
