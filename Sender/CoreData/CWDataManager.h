//
//  CWDataManager.h
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "Message.h"

@interface CWDataManager : NSObject
+ (id)sharedInstance;

@property (nonatomic, strong) NSManagedObjectContext * moc;

- (void) setupCoreData;
- (Message *)importMessage:(NSString *)messageID chatwalaZipURL:(NSURL *)zipURL withError:(NSError **)error;

- (Message *) findMessageByMessageID:(NSString*) messageID;

- (Message *)createMessageWithSender:(NSString *)senderID inResponseToIncomingMessage:(Message *) incomingMessage;
- (Message *) createMessageWithDictionary:(NSDictionary *) sourceDictionary error:(NSError **)error;

+ (NSDateFormatter *)dateFormatter;

// Data queries
+ (void)markAllMessagesAsReadForUser:(NSString *)userID;
+ (void)markAllMessagesAsDeviceDeletedForUser:(NSString *)userID;
+ (NSInteger)totalUnreadMessagesForRecipient:(NSString *)userID;
+ (NSArray *)fetchGroupBySenderID;
+ (NSArray *)fetchMessagesForSender:(NSString *)senderID;
+ (Message *)messageWithThreadID:(NSString *)threadID withThreadIndex:(NSInteger)threadIndex;

@end
