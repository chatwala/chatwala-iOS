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
@property (nonatomic,weak) IBOutlet UITableView * messagesTable;
@property (nonatomic,weak) IBOutlet UILabel * messagesLabel;
@property (nonatomic,weak) IBOutlet UIButton * plusButton;
@property (nonatomic,weak) IBOutlet UIButton * settingsButton;
@property (nonatomic,weak) id<CWInboxDelegate> delegate;
- (IBAction)onButtonSelect:(id)sender;
@end



@protocol CWInboxDelegate <NSObject>
- (void)inboxViewController:(CWInboxViewController*)inboxVC didSelectButton:(UIButton*)button;
- (void)inboxViewController:(CWInboxViewController*)inboxVC didSelectMessage:(Message *)message;
@end