//
//  CWInboxMessagesViewController.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/26/14.
//  Copyright (c) 2014 Chatwala. All rights reserved.
//

#import "CWInboxMessagesController.h"
#import "CWMessageCell.h"

@interface CWInboxMessagesController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation CWInboxMessagesController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [self.tableView registerClass:[CWMessageCell class] forCellReuseIdentifier:[CWMessageCell cellIdentifier]];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(inboxViewController:didSelectMessage:)]) {
        [self.delegate inboxViewController:nil didSelectMessage:message];
        message.eMessageViewedState = eMessageViewedStateOpened;
        
        CWMessageCell *messageCell = (CWMessageCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self updateCellState:messageCell withMessage:message];
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

- (void)configureCell:(CWMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    [cell setMessage:message];
    [cell configureStatusFromMessageViewedState:message.eMessageViewedState];
}

- (void)updateCellState:(CWMessageCell *)cell withMessage:(Message *)message {
    
    [cell configureStatusFromMessageViewedState:message.eMessageViewedState];
}

@end
