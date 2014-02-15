//
//  CWDataManager.h
//  Sender
//
//  Created by randall chatwala on 1/8/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Thread.h"

@interface CWDataManager : NSObject
+ (id)sharedInstance;

@property (nonatomic, strong) NSManagedObjectContext * moc;

- (void) setupCoreData;
- (Message *) importMessageAtFilePath:(NSURL *) filePath withError:(NSError **)error;

- (Message *) findMessageByMessageID:(NSString*) messageID;
- (User *) findUserByUserID:(NSString *) userID;
- (User *) createUserWithID:(NSString *) userID;
- (Thread *) findThreadByThreadID:(NSString*) threadID;
- (Thread *) createThreadWithID:(NSString *) threadID;

- (Message *) createMessageWithSender:(User *) sender inResponseToIncomingMessage:(Message *) incomingMessage;
- (Message *) createMessageWithDictionary:(NSDictionary *) sourceDictionary error:(NSError **)error;


+ (NSString*)cacheDirectoryPath;
+ (NSDateFormatter *)dateFormatter;
@end
