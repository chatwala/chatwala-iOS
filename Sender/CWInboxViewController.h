//
//  CWInboxViewController.h
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

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
- (void)menuViewController:(CWInboxViewController*)menuVC didSelectButton:(UIButton*)button;
- (void)menuViewController:(CWInboxViewController*)menuVC didSelectMessageWithID:(NSString*)messageId;
@end