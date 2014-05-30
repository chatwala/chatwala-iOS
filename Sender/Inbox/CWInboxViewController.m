//
//  CWInboxViewController.m
//  Sender
//
//  Created by Khalid on 12/17/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWInboxViewController.h"
#import "CWMessageManager.h"
#import "CWUserCell.h"
#import "CWUserManager.h"
#import "Message.h"
#import "CWDataManager.h"
#import "CWInboxMessagesController.h"
#import "CWConstants.h"
#import "CWAppFeedBackViewController.h"

static const float InboxTableTransitionDuration = 0.3f;

@interface CWInboxViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) UITableView *usersTableView;

@property (nonatomic) CWInboxMessagesController *messagesController;

@property (nonatomic,strong) UIRefreshControl * refreshControl;

@property (nonatomic) NSArray *distinctUsersMessages;
@property (nonatomic) BOOL isShowingMessagesTable;

@end

@implementation CWInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    self.distinctUsersMessages = [CWDataManager fetchGroupBySenderID];
    
    self.settingsButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.settingsButton setImage:[UIImage imageNamed:@"settings_cog"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(onSettingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
    
    self.plusButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.plusButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:42.0f];
    self.plusButton.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:70.0f/255.0f blue:96.0f/255.0f alpha:1.0f];
    [self.plusButton setTitle:@"+" forState:UIControlStateNormal];
    [self.plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.plusButton addTarget:self action:@selector(onButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.plusButton];
    
    self.usersTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.usersTableView registerClass:[CWUserCell class] forCellReuseIdentifier:[CWUserCell cellIdentifier]];
    [self.usersTableView setDelegate:self];
    [self.usersTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.usersTableView setDataSource:self];
    
    [self.usersTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.usersTableView];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.usersTableView addSubview:self.refreshControl];
    
    
    self.messagesController = [[CWInboxMessagesController alloc] init];
    self.messagesController.delegate = self.delegate;
    
    [self.view addSubview:self.messagesController.tableView];
    
    
    [NC addObserver:self selector:@selector(onMessagesLoaded:) name:@"MessagesLoaded" object:nil];
    [NC addObserver:self selector:@selector(onMessagLoadedFailed:) name:@"MessagesLoadFailed" object:nil];
    [NC addObserver:self selector:@selector(messageSent:) name:CWNotificationMessageSent object:nil];
    [NC addObserver:self selector:@selector(shouldMarkAllMessagesAsRead:) name:CWNotificationShouldMarkAllMessagesAsRead object:nil];
    [NC addObserver:self selector:@selector(handleInboxOpenNotification:) name:(NSString *)CWNotificationInboxViewControllerShouldOpenInbox object:nil];
    
    [NC addObserver:self selector:@selector(showUsersTable:) name:CWNotificationInboxShouldShowUsersTable object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Have to set frames here because the view isn't correctly configured in viewDidLoad
    self.settingsButton.frame = CGRectMake(0.0f, self.view.frame.size.height - 50.0f, self.view.bounds.size.width, 50.0f);
    self.plusButton.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 69.0f);
    
    // Only reset the frame if we're in the user table
    if (!self.isShowingMessagesTable) {

        self.usersTableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.plusButton.frame), self.view.frame.size.width, self.settingsButton.frame.origin.y - CGRectGetMaxY(self.plusButton.frame));

        self.messagesController.tableView.frame = CGRectMake(CGRectGetMaxX(self.view.frame), self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
    }

    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUserID] withCompletionOrNil:nil];
}

#pragma mark - Notification handlers

- (void)onMessagesLoaded:(NSNotification *)note {

    self.distinctUsersMessages = [CWDataManager fetchGroupBySenderID];
    
    [self.usersTableView reloadData];
    [self.messagesController.tableView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)onMessagLoadedFailed:(NSNotification*)note {

    [self.refreshControl endRefreshing];
}

- (void)handleRefresh:(UIRefreshControl*)r {

    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUserID] withCompletionOrNil:nil];
}

- (void)messageSent:(NSNotification *)notification {
    [self hideMessagesTableAnimated:NO];
}

- (void)shouldMarkAllMessagesAsRead:(NSNotification *)notification {
    [CWDataManager markAllMessagesAsReadForUser:[[CWUserManager sharedInstance] localUserID]];
    [self.usersTableView reloadData];
    [self.messagesController.tableView reloadData];
}

- (void)handleInboxOpenNotification:(NSNotification *)notification {
    [self hideMessagesTableAnimated:NO];
}

- (void)showUsersTable:(NSNotification *)notification {
    [self hideMessagesTableAnimated:YES];
}

#pragma mark - Convenience methods to support group by user

- (void)showMessagesTableWithMessages:(NSMutableArray *)messages animated:(BOOL)shouldAnimate {
    
    self.messagesController.messages = messages;
    [self.messagesController.tableView reloadData];
    [self.messagesController.tableView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:NO];
    
    if (shouldAnimate) {
        [UIView animateWithDuration:InboxTableTransitionDuration animations:^{
            
            self.usersTableView.frame = CGRectMake(- self.usersTableView.frame.size.width, self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
            
            self.messagesController.tableView.frame = CGRectMake(0.0f, self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
            
        } completion:^(BOOL finished) {
            [self showBackButton];
        }];
    }
    else {
        self.usersTableView.frame = CGRectMake(- self.usersTableView.frame.size.width, self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
        
        self.messagesController.tableView.frame = CGRectMake(0.0f, self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
        [self showBackButton];
    }
}

- (void)hideMessagesTableAnimated:(BOOL)shouldAnimate {
    
    if (shouldAnimate) {
        [UIView animateWithDuration:InboxTableTransitionDuration animations:^{
            
            self.usersTableView.frame = CGRectMake(0.0f, self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
            
            self.messagesController.tableView.frame = CGRectMake(CGRectGetMaxX(self.view.frame), self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
            
        } completion:^(BOOL finished) {
            // Disable button?
            [self hideBackButton];
        }];
    }
    else {
        self.usersTableView.frame = CGRectMake(0.0f, self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
        
        self.messagesController.tableView.frame = CGRectMake(CGRectGetMaxX(self.view.frame), self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);

        [self hideBackButton];
    }
    
    // Update because cells might have been deleted from the messages table affecting what user cells to show
    self.distinctUsersMessages = [CWDataManager fetchGroupBySenderID];
    [self.usersTableView reloadData];
}

- (void)showBackButton {
    self.isShowingMessagesTable = YES;
    self.plusButton.titleLabel.text = @"<";
}

- (void)hideBackButton {
    self.isShowingMessagesTable = NO;
    self.plusButton.titleLabel.text = @"+";
}

#pragma mark - User Interactions

- (void)onButtonSelect:(id)sender {
    if (!self.isShowingMessagesTable && [self.delegate respondsToSelector:@selector(inboxViewController:didSelectTopButton:)]) {
        [self.delegate inboxViewController:self didSelectTopButton:sender];
    }
    else if (self.isShowingMessagesTable) {
        [self hideMessagesTableAnimated:YES];
    }
}

- (IBAction)onSettingsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectSettingsButton:)]) {
        [self.delegate inboxViewController:self didSelectSettingsButton:sender];
    }
}

- (void)didTapFeedbackFooter:(id)sender {
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:[[CWAppFeedBackViewController alloc] init]];
    
    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    [navController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - CWUserCell UI convenience methods


- (void)configureCell:(CWUserCell *)cell atIndexPath:(NSIndexPath *)indexPath {
 
    NSArray *messagesForSender = [self.distinctUsersMessages objectAtIndex:indexPath.row];
    
    
    if ([messagesForSender count]) {
    
        Message *message = [messagesForSender objectAtIndex:0];
        [cell setMessage:message];
        [self updateCellState:cell withMessage:message];
    }
}

- (void)updateCellState:(CWUserCell *)cell withMessage:(Message *)message {
    
    // Let's see if we need to show a red dot for this user
    NSInteger numberOfUnread = [CWUserManager numberOfUnreadMessagesForRecipient:message.senderID];
    if (numberOfUnread > 0) {
        // Hacking unopened b/c that results in a red dot appearing
        [cell configureStatusFromMessageViewedState:eMessageViewedStateUnOpened];
    }
    else {
        [cell configureStatusFromMessageViewedState:eMessageViewedStateRead];
    }
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *arrayOfMessagesForSender = [self.distinctUsersMessages objectAtIndex:indexPath.row];
    CWUserCell *userCell = (CWUserCell *)[tableView cellForRowAtIndexPath:indexPath];

    Message *message = [arrayOfMessagesForSender objectAtIndex:0];
    
    if ([arrayOfMessagesForSender count] == 1 && message.eMessageViewedState == eMessageViewedStateUnOpened) {

        if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectMessage:)]) {
            [self.delegate inboxViewController:nil didSelectMessage:message];
            message.eMessageViewedState = eMessageViewedStateOpened;
            
            [self updateCellState:userCell withMessage:message];
        }
    }
    else {
    
        [self showMessagesTableWithMessages:arrayOfMessagesForSender animated:YES];
        [self updateCellState:userCell withMessage:[arrayOfMessagesForSender objectAtIndex:0]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [CWUserCell cellIdentifier];
    CWUserCell *cell = (CWUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.distinctUsersMessages count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIButton *feedbackFooterButton = nil;
    
    if (section == 0) {
        feedbackFooterButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 72.0f)];
        feedbackFooterButton.backgroundColor = [UIColor blackColor];
        [feedbackFooterButton setImage:[UIImage imageNamed:@"FeedbackButton"] forState:UIControlStateNormal];
        [feedbackFooterButton setImage:[UIImage imageNamed:@"FeedbackButtonTapped"] forState:UIControlStateHighlighted];
        
        [feedbackFooterButton addTarget:self action:@selector(didTapFeedbackFooter:) forControlEvents:UIControlEventTouchUpInside];
    }
    

    return feedbackFooterButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 72.0f;
}

@end
