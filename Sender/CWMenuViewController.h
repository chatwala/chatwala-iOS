//
//  CWMenuViewController.h
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CWMenuDelegate;

@interface CWMenuViewController : UIViewController
@property (nonatomic,weak) IBOutlet UITableView * messagesTable;
@property (nonatomic,weak) IBOutlet UILabel * messagesLabel;
@property (nonatomic,weak) IBOutlet UIButton * plusButton;
@property (nonatomic,weak) IBOutlet UIButton * settingsButton;
@property (nonatomic,weak) id<CWMenuDelegate> delegate;
- (IBAction)onButtonSelect:(id)sender;
@end



@protocol CWMenuDelegate <NSObject>
- (void)menuViewController:(CWMenuViewController*)menuVC didSelectButton:(UIButton*)button;
- (void)menuViewController:(CWMenuViewController*)menuVC didSelectMessageWithID:(NSString*)messageId;
@end