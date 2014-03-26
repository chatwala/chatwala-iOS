//
//  CWMessageSender.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/27/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

@class User;
@class Message;

@protocol CWMessageSenderDelegate;

@interface CWMessageSender : NSObject

@property (nonatomic,weak) id<CWMessageSenderDelegate> delegate;

@property (nonatomic) Message *messageBeingSent;
@property (nonatomic) Message *messageBeingRespondedTo;

- (void)sendMessageFromUser:(NSString *)userID;
- (void)cancel;

@end

@protocol CWMessageSenderDelegate <NSObject>

@required

- (void)messageSender:(CWMessageSender *)messageSender shouldPresentMessageComposerController:(UINavigationController *)composerNavController;
- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender;
- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender;
- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error;

@end