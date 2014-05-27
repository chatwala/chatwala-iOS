//
//  CWInboxViewController.h
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

@class Message;
@protocol CWInboxDelegate;

@interface CWInboxViewController : UIViewController

@property (nonatomic) UIButton *plusButton;
@property (nonatomic) UIButton *settingsButton;
@property (nonatomic,weak) id<CWInboxDelegate> delegate;

@end



@protocol CWInboxDelegate <NSObject>

@required
- (void)inboxViewController:(CWInboxViewController *)inboxVC didSelectTopButton:(UIButton *)button;
- (void)inboxViewController:(CWInboxViewController *)inboxVC didSelectSettingsButton:(UIButton *)button;
- (void)inboxViewController:(CWInboxViewController *)inboxVC didSelectMessage:(Message *)message;

@optional
- (void)inboxDidSelectCreateNewMessageToUser:(NSString *)toRecipientID withProfileImage:(UIImage *)profileImage;

@end