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

@interface CWMenuViewController ()
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
    [self.messagesTable setDelegate:[CWMessageManager sharedInstance]];
    [self.messagesTable setDataSource:[CWMessageManager sharedInstance]];
//    [self.messagesTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.messagesTable addSubview:self.refreshControl];
    
    
    [NC addObserver:self selector:@selector(onMessagesLoaded:) name:@"MessagesLoaded" object:nil];
    [NC addObserver:self selector:@selector(onMessagLoadedFailed:) name:@"MessagesLoadFailed" object:nil];
    
    [[CWMessageManager sharedInstance]getMessages];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.messagesTable reloadData];
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
    [self.messagesLabel setText:[NSString stringWithFormat:@"%d Messages",[[[CWMessageManager sharedInstance]messages] count]]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[CWMessageManager sharedInstance]messages] count]];
    
}

- (void)onMessagLoadedFailed:(NSNotification*)note
{
    [self.messagesLabel setText:@"failed to load messages."];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[CWMessageManager sharedInstance]messages] count]];
}

- (void)handleRefresh:(UIRefreshControl*)r
{
    [[CWMessageManager sharedInstance]getMessages];
}
@end
