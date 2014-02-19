//
//  CWInboxViewController.m
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWInboxViewController.h"
#import "CWMessageManager.h"
#import "CWMessageCell.h"
#import "CWUserManager.h"
#import "Message.h"



@interface CWInboxViewController () <UITableViewDelegate>
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end

@implementation CWInboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.messagesTable registerClass:[CWMessageCell class] forCellReuseIdentifier:@"messageCell"];
//    [self.messagesTable setDelegate:[CWMessageManager sharedInstance]];
    [self.messagesTable setDelegate:self];
    [self.messagesTable setDataSource:[CWMessageManager sharedInstance]];
//    [self.messagesTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.messagesTable addSubview:self.refreshControl];
    
    
    [NC addObserver:self selector:@selector(onMessagesLoaded:) name:@"MessagesLoaded" object:nil];
    [NC addObserver:self selector:@selector(onMessagLoadedFailed:) name:@"MessagesLoadFailed" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUser] withCompletionOrNil:nil];
    [self.messagesTable reloadData];
}

- (void)onMessagesLoaded:(NSNotification *)note {

    NSOrderedSet * inboxMessages = [[[CWUserManager sharedInstance] localUser] inboxMessages];
    [self.messagesLabel setText:[NSString stringWithFormat:@"%d Messages", inboxMessages.count]];
    
    [self.messagesTable reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)onMessagLoadedFailed:(NSNotification*)note {

    [self.messagesLabel setText:@"failed to load messages."];
    [self.refreshControl endRefreshing];
}

- (void)handleRefresh:(UIRefreshControl*)r {

    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUser] withCompletionOrNil:nil];
}

- (IBAction)onButtonSelect:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectButton:)]) {
        [self.delegate inboxViewController:self didSelectButton:sender];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    User *localUser = [[CWUserManager sharedInstance] localUser];
    NSOrderedSet *inboxMessages = [localUser inboxMessages];
    Message *message = [inboxMessages objectAtIndex:indexPath.row];
  
    if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectMessageWithID:)]) {
        [self.delegate inboxViewController:self didSelectMessageWithID:message.messageID];
        message.eMessageViewedState = eMessageViewedStateOpened;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

@end
