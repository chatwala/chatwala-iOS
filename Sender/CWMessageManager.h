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

@interface CWMessageManager : NSObject < UITableViewDataSource, UITableViewDelegate>
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
- (void)uploadMesage:(CWMessageItem *)messageToUpload isReply:(BOOL)isReplyMessage;

@end
