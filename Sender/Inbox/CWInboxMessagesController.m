//
//  CWInboxMessagesViewController.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/26/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWInboxMessagesController.h"
#import "CWMessageCell.h"
#import "CWUserManager.h"
#import "CWConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const float DeleteMessageLongPressDuration = 1.0f;

@interface CWInboxMessagesController () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic) NSIndexPath *deletionIndexPath;
@property (nonatomic) UIActionSheet *deleteActionSheet;

@property (nonatomic) UIImage *footerImage;

@end

@implementation CWInboxMessagesController


- (id)init {
    
    self = [super init];
    if (self) {
        // Custom initialization
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [self.tableView registerClass:[CWMessageCell class] forCellReuseIdentifier:[CWMessageCell cellIdentifier]];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                             initWithTarget:self action:@selector(handleLongPress:)];
        longPressRecognizer.minimumPressDuration = DeleteMessageLongPressDuration;
        [self.tableView addGestureRecognizer:longPressRecognizer];
        
        [NC addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NC removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - UIGestureRecognizer

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        
    }
    else {
        CWMessageCell *cell = (CWMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.isDeleteModeEnabled = YES;
        
        self.deletionIndexPath = indexPath;
        self.deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure? This will permanently delete this video message." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        if (window) {
            [self.deleteActionSheet showInView:window];
        }
    }
}

#pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    CWMessageCell *cell = (CWMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectMessage:)]) {
        [self.delegate inboxViewController:nil didSelectMessage:message];
        message.eMessageViewedState = eMessageViewedStateOpened;
        
        [self updateCellState:cell withMessage:message];
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
    
    NSString *CellIdentifier = [CWMessageCell cellIdentifier];
    CWMessageCell *cell = (CWMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self messages] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    // 1. The view for the header
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 72.0f)];
    footerView.layer.borderColor = [UIColor blackColor].CGColor;
    footerView.layer.borderWidth = 1.0f;
    
    // 2. Set a custom background color
    footerView.backgroundColor = [UIColor colorWithRed:122.0f/255.0f green:24.0f/255.0f blue:68.0f/255.0f alpha:1.0f];
    
    // 3. Add a label
    UILabel* footerLabel = [[UILabel alloc] init];
    footerLabel.frame = CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 72.0f);
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [UIColor chatwalaFeedbackLabel];
    footerLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:14.0f];
    footerLabel.text = @"NEW";
    footerLabel.textAlignment = NSTextAlignmentCenter;

    [footerView addSubview:footerLabel];

    // 4. Load up the first message from that user to obtain their profile pic URL
    Message *message = [self.messages objectAtIndex:0];
    UIImageView *newMessageImageView = [[UIImageView alloc] initWithFrame:footerView.frame];
    newMessageImageView.contentMode = UIViewContentModeScaleAspectFill;
    newMessageImageView.clipsToBounds = YES;
    newMessageImageView.alpha = 0.3f;


    // 5. Add control to monitor touches
    __block UIControl *feedbackFooterControl = [[UIControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 72.0f)];
    feedbackFooterControl.enabled = NO;
    feedbackFooterControl.backgroundColor = [UIColor clearColor];
    [feedbackFooterControl addTarget:self action:@selector(didTapNewMessageFooter:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:feedbackFooterControl];
    
    [newMessageImageView setImageWithURL:[NSURL URLWithString:message.userThumbnailURL] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        if (!error) {

            self.footerImage = image;
            feedbackFooterControl.enabled = YES;
        }
    }];
    
    [footerView addSubview:newMessageImageView];
    [footerView bringSubviewToFront:footerLabel];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 72.0f;
}

#pragma mark - Table convenicence methods

- (void)configureCell:(CWMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    [cell setMessage:message];
    [cell configureStatusFromMessageViewedState:message.eMessageViewedState];
}

- (void)updateCellState:(CWMessageCell *)cell withMessage:(Message *)message {
    
    [cell configureStatusFromMessageViewedState:message.eMessageViewedState];
}

#pragma mark - UIActionSheet callback

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (!self.deletionIndexPath) {
        return;
    }
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        CWMessageCell *cell = (CWMessageCell *)[self.tableView cellForRowAtIndexPath:self.deletionIndexPath];
        cell.isDeleteModeEnabled = NO;
    }
    else {
        [self deleteMessageAtIndexPath:self.deletionIndexPath];
    }
    
    self.deletionIndexPath = nil;
}

- (void)deleteMessageAtIndexPath:(NSIndexPath *)indexPathToDelete {
    Message *message = [self.messages objectAtIndex:indexPathToDelete.row];
    
    [message deleteMessageFromInbox];
    
    [self.messages removeObjectAtIndex:indexPathToDelete.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete] withRowAnimation:UITableViewRowAnimationFade];
    
    
    if (![self.messages count]) {
        // No more messages showing at this level, let's kick back to the users table
        [NC postNotificationName:CWNotificationInboxShouldShowUsersTable object:nil userInfo:nil];
    }
}

#pragma mark - User Interaction

- (void)didTapNewMessageFooter:(id)sender {
    NSLog(@"User tapped create new message cell");

    if ([self.delegate respondsToSelector:@selector(inboxDidSelectCreateNewMessageToUser:withProfileImage:)]) {
        Message *firstMessage = [self.messages objectAtIndex:0];
        [self.delegate inboxDidSelectCreateNewMessageToUser:firstMessage.senderID withProfileImage:self.footerImage];
    }
}

#pragma mark - UIApplication handling

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self.deleteActionSheet dismissWithClickedButtonIndex:self.deleteActionSheet.cancelButtonIndex animated:NO];
    
    CWMessageCell *cell = (CWMessageCell *)[self.tableView cellForRowAtIndexPath:self.deletionIndexPath];
    cell.isDeleteModeEnabled = NO;
}

@end