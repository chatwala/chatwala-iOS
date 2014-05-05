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
- (Message *)importMessage:(NSString *)messageID chatwalaZipURL:(NSURL *)zipURL isInboxMessage:(BOOL)inboxMessage withError:(NSError **)error;

- (Message *) findMessageByMessageID:(NSString*) messageID;
//- (User *) findUserByUserID:(NSString *) userID;
//- (User *) createUserWithID:(NSString *) userID;
//- (Thread *) findThreadByThreadID:(NSString*) threadID;
//- (Thread *) createThreadWithID:(NSString *) threadID;

- (Message *)createMessageWithSender:(NSString *)senderID inResponseToIncomingMessage:(Message *) incomingMessage videoURL:(NSURL *)videoURL;
- (Message *) createMessageWithDictionary:(NSDictionary *) sourceDictionary error:(NSError **)error;

+ (NSDateFormatter *)dateFormatter;
@end
