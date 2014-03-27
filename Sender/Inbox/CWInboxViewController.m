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

static const float InboxTableTransitionDuration = 0.3f;

@interface CWInboxViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView * usersTableView;

@property (nonatomic) CWInboxMessagesController *messagesController;

@property (nonatomic,strong) UIRefreshControl * refreshControl;

@property (nonatomic) NSArray *distinctUserMessages;
@property (nonatomic) BOOL shouldTreatAsBackButton;

@end

@implementation CWInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.distinctUserMessages = [AOFetchUtilities fetchGroupBySenderID];
    self.view.clipsToBounds = YES;
    
    // Do any additional setup after loading the view from its nib.
    [self.usersTableView registerClass:[CWUserCell class] forCellReuseIdentifier:[CWUserCell cellIdentifier]];
//    [self.messagesTable setDelegate:[CWMessageManager sharedInstance]];
    [self.usersTableView setDelegate:self];
    [self.usersTableView setDataSource:self];
//    [self.messagesTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.usersTableView addSubview:self.refreshControl];
    
    
    self.messagesController = [[CWInboxMessagesController alloc] init];
    self.messagesController.delegate = self.delegate;
    
    self.messagesController.tableView.frame = CGRectMake(CGRectGetMaxX(self.view.frame), self.usersTableView.frame.origin.y, self.usersTableView.frame.size.width, self.usersTableView.frame.size.height);
    [self.view addSubview:self.messagesController.tableView];
    
    
    [NC addObserver:self selector:@selector(onMessagesLoaded:) name:@"MessagesLoaded" object:nil];
    [NC addObserver:self selector:@selector(onMessagLoadedFailed:) name:@"MessagesLoadFailed" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.distinctUserMessages = [AOFetchUtilities fetchGroupBySenderID];
    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUserID] withCompletionOrNil:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - Notification handlers

- (void)onMessagesLoaded:(NSNotification *)note {

//    NSOrderedSet * inboxMessages = [[CWUserManager sharedInstance]] inboxMessages];
//    [self.messagesLabel setText:[NSString stringWithFormat:@"%lu Messages", (unsigned long)inboxMessages.count]];
    
    [self.usersTableView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
}

- (void)onMessagLoadedFailed:(NSNotification*)note {

//    [self.messagesLabel setText:@"failed to load messages."];
    [self.refreshControl endRefreshing];
}

- (void)handleRefresh:(UIRefreshControl*)r {

    [[CWMessageManager sharedInstance] getMessagesForUser:[[CWUserManager sharedInstance] localUserID] withCompletionOrNil:nil];
}

#pragma mark - Convenience methods to support group by user

- (void)showMessagesTableWithMessages:(NSArray *)messages animated:(BOOL)shouldAnimate {
    
    self.messagesController.messages = messages;
    [self.messagesController.tableView reloadData];
    
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
}

- (void)showBackButton {
    self.shouldTreatAsBackButton = YES;
    self.plusButton.titleLabel.text = @"<";
}

- (void)hideBackButton {
    self.shouldTreatAsBackButton = NO;
    self.plusButton.titleLabel.text = @"+";
}

#pragma mark - User Interactions

- (IBAction)onButtonSelect:(id)sender {
    if (!self.shouldTreatAsBackButton && [self.delegate respondsToSelector:@selector(inboxViewController:didSelectTopButton:)]) {
        [self.delegate inboxViewController:self didSelectTopButton:sender];
    }
    else if (self.shouldTreatAsBackButton) {
        [self hideMessagesTableAnimated:YES];
    }
}

- (IBAction)onSettingsButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectSettingsButton:)]) {
        [self.delegate inboxViewController:self didSelectSettingsButton:sender];
    }
}


#pragma mark - CWUserCell UI convenience methods


- (void)configureCell:(CWMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
 
    NSDictionary *resultsForSender = [self.distinctUserMessages objectAtIndex:indexPath.row];
    NSString *senderID = [resultsForSender objectForKey:@"senderID"];
    
    Message *message = [Message messageFromSenderID:senderID andTimestamp:[resultsForSender objectForKey:@"maxTimestamp"]];
    [cell setMessage:message];
    
    // Let's see if we need to show a red dot for this user
    NSInteger numberOfUnread = [CWUserManager numberOfUnreadMessagesForUser:senderID];
    if (numberOfUnread > 0) {
        
        // Hacking unopened b/c that results in a red dot appearing
        [cell configureStatusFromMessageViewedState:eMessageViewedStateUnOpened];
    }
    else {
        [cell configureStatusFromMessageViewedState:eMessageViewedStateRead];
    }
}

- (void)updateCellState:(CWUserCell *)cell withMessage:(Message *)message {
    
    [cell configureStatusFromMessageViewedState:message.eMessageViewedState];
}


#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *resultsForSender = [self.distinctUserMessages objectAtIndex:indexPath.row];
    NSArray *arrayOfMessagesForSender = [AOFetchUtilities fetchMessagesForUser:[resultsForSender objectForKey:@"senderID"]];
    
    if ([arrayOfMessagesForSender count] == 1) {
        Message *message = [arrayOfMessagesForSender objectAtIndex:0];
        
        if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectMessage:)]) {
            [self.delegate inboxViewController:nil didSelectMessage:message];
            message.eMessageViewedState = eMessageViewedStateOpened;
            
            CWUserCell *userCell = (CWUserCell *)[tableView cellForRowAtIndexPath:indexPath];
            [self updateCellState:userCell withMessage:message];
        }
    }
    else if ([arrayOfMessagesForSender count] > 1) {

        [self showMessagesTableWithMessages:arrayOfMessagesForSender animated:YES];
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
    
    // TODO: Make this a constant
    NSString *CellIdentifier = [CWUserCell cellIdentifier];
    CWUserCell *cell = (CWUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
//    NSInteger numberOfObjects = [sectionInfo numberOfObjects];
//    
    return [self.distinctUserMessages count];
}

#pragma mark - UIFetchResults controller methods

//- (NSFetchedResultsController *)fetchedResultsController {
//    
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    NSManagedObjectContext *managedObjectContext = [[CWDataManager sharedInstance] moc];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:@"Message" inManagedObjectContext:managedObjectContext];
//    
//    
//    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"timeStamp"]; // Does not really matter
//    NSExpression *maxExpression = [NSExpression expressionForFunction: @"max:"
//                                                            arguments: [NSArray arrayWithObject:keyPathExpression]];
//    
//    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
//    
//    [expressionDescription setName: @"maxTimestamp"];
//    [expressionDescription setExpression:maxExpression];
//    [expressionDescription setExpressionResultType:NSDateAttributeType];
//    
//    
//    //    NSExpression *messageKeyPathExpression = [NSExpression expressionForKeyPath: @"messageID"];
//    //    NSExpression *countExpression = [NSExpression expressionForFunction: @"count:"
//    //                                                              arguments: [NSArray arrayWithObject:messageKeyPathExpression]];
//    
//    
//    //    NSExpressionDescription *countDescription = [[NSExpressionDescription alloc] init];
//    //
//    //    [countDescription setName: @"countMessages"];
//    //    [countDescription setExpression:countExpression];
//    //    [countDescription setExpressionResultType:NSInteger32AttributeType];
//    //
//    [fetchRequest setEntity:entity];
//    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"senderID", expressionDescription, nil]];
//    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"senderID",nil]];
//    
//    // Remove our own user from the sender list...
//    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"senderID!=%@", [[CWUserManager sharedInstance] localUserID]];
//    //    [fetchRequest setPredicate:predicate];
//    [fetchRequest setResultType:NSDictionaryResultType];
//    
//    // Sort the results by the most recent message
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO]]];
//    
//    // TODO: Add cache?
//    NSFetchedResultsController *theFetchedResultsController =
//    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
//                                                   cacheName:nil];
//    self.fetchedResultsController = theFetchedResultsController;
//    return _fetchedResultsController;
//}

@end
