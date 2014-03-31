//
//  CWInboxMessagesViewController.h
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/26/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWInboxViewController.h"

@interface CWInboxMessagesController : UIViewController

@property (nonatomic) NSArray *messages;

@property (nonatomic) UITableView *tableView;
@property (nonatomic,weak) id<CWInboxDelegate> delegate;

@end
