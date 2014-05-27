//
//  CWMessageSender.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/27/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

@class User;
@class Message;

@protocol CWMessageSenderDelegate;

// TODO: Need a better approach here
typedef enum CWMessageSenderMessageType {
    CWMessageSenderMessageTypeStarterToUnknownRecipient = 0,
    CWMessageSenderMessageTypeStarterToKnownRecipient,
    CWMessageSenderMessageTypeReply,
} CWMessageSenderMessageType;


@interface CWMessageSender : NSObject

@property (nonatomic,weak) id<CWMessageSenderDelegate> delegate;

@property (nonatomic) Message *messageBeingSent;
@property (nonatomic) Message *messageBeingRespondedTo;


@property (nonatomic, assign) CWMessageSenderMessageType messageType;

- (void)sendMessageFromUser:(NSString *)userID;
- (void)cancel;

@end

@protocol CWMessageSenderDelegate <NSObject>

@required

- (void)messageSender:(CWMessageSender *)messageSender shouldPresentMessageComposerController:(UINavigationController *)composerNavController;
- (void)messageSenderDidSucceedMessageSend:(CWMessageSender *)messageSender forMessage:(Message *)sentMessage;
- (void)messageSenderDidCancelMessageSend:(CWMessageSender *)messageSender;
- (void)messageSender:(CWMessageSender *)messageSender didFailMessageSend:(NSError *)error;

@end