//
//  CWMenuViewController.m
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMenuViewController.h"
#import "CWMessageManager.h"
#import "CWMessageCell.h"
#import "CWUserManager.h"
#import "Message.h"



@interface CWMenuViewController () <UITableViewDelegate>
@property (nonatomic,strong) UIRefreshControl * refreshControl;
@end

@implementation CWMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[CWUserManager sharedInstance] localUser:^(User *localUser) {
        [[CWMessageManager sharedInstance] getMessagesForUser:localUser withCompletionOrNil:nil];
        [self.messagesTable reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMessagesLoaded:(NSNotification*)note
{
    [self.messagesTable reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [[CWUserManager sharedInstance] localUser:^(User *localUser) {
        NSOrderedSet * inboxMessages = [localUser inboxMessages];
        
        [self.messagesLabel setText:[NSString stringWithFormat:@"%d Messages", inboxMessages.count]];
    }];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[CWMessageManager sharedInstance]messages] count]];
    
}

- (void)onMessagLoadedFailed:(NSNotification*)note
{
    [self.messagesLabel setText:@"failed to load messages."];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[CWMessageManager sharedInstance]messages] count]];
    
    [self.refreshControl endRefreshing];
}

- (void)handleRefresh:(UIRefreshControl*)r
{
    [[CWUserManager sharedInstance] localUser:^(User *localUser) {
        [[CWMessageManager sharedInstance] getMessagesForUser:localUser withCompletionOrNil:nil];
    }];
}

- (IBAction)onButtonSelect:(id)sender {
    if ([self.delegate respondsToSelector:@selector(menuViewController:didSelectButton:)]) {
        [self.delegate menuViewController:self didSelectButton:sender];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User * localUser = [[CWUserManager sharedInstance] localUser];
    NSOrderedSet * inboxMessages = [localUser inboxMessages];
    Message * message = [inboxMessages objectAtIndex:indexPath.row];
    
    NSString* messageId = message.messageID;
  
    if ([self.delegate respondsToSelector:@selector(menuViewController:didSelectMessageWithID:)]) {
        [self.delegate menuViewController:self didSelectMessageWithID:messageId];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

@end
