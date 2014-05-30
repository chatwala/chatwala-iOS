//
//  CWSettingsViewController.m
//  Sender
//
//  Created by Khalid on 12/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSettingsViewController.h"
#import "CWTermsViewController.h"
#import "CWPrivacyViewController.h"
#import "CWAppFeedBackViewController.h"
#import "CWProfilePictureViewController.h"
#import "UIColor+Additions.h"
#import "CWTableViewCellNewMessageDeliveryMethodCell.h"
#import "CWTableViewShowMessagePreviewCell.h"
#import "CWUserManager.h"
#import "CWUserDefaultsController.h"
#import "CWMessageManager.h"

NSInteger const MarkAllMessagesAsReadIndex  = 3;
NSInteger const ClearFileSpaceIndex  = 4;
NSInteger const ToggleMessageDeliveryMethodIndex  = 5;
NSInteger const ToggleShowMessagePreviewIndex     = 6;

@interface CWSettingsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet CWTableViewCellNewMessageDeliveryMethodCell *deliveryMethodCell;
@property (strong, nonatomic) IBOutlet CWTableViewShowMessagePreviewCell *messagePreviewCell;

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (nonatomic,strong) NSArray * sectionHeaders;
@property (nonatomic,strong) NSArray * section1Titles;
@property (nonatomic,strong) NSArray * section2Titles;
@end

@implementation CWSettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.settingsTable registerClass:[CWTableViewCellNewMessageDeliveryMethodCell class] forCellReuseIdentifier:@"deliveryMethod"];
    
    [self.settingsTable registerClass:[CWTableViewShowMessagePreviewCell class] forCellReuseIdentifier:@"showMessagePreview"];

    UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSettingsDone)];
    
    [self.navigationItem setRightBarButtonItem:doneBtn];
    [self.navigationItem setTitle:@"SETTINGS"];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setSectionHeaders:@[@"",@""]];

    NSDictionary * att = @{
                           NSForegroundColorAttributeName: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]
                           };
    [self.navigationController.navigationBar setTitleTextAttributes:att];
    
    [self setSection1Titles:@[@"Terms and Conditions",@"Privacy Policy", @"Edit Your Profile Picture", @"Mark All Messages As Read", @"Clear File Space"]];
    
    [self.settingsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"settingsCell"];
    [self.settingsTable setDelegate:self];
    [self.settingsTable setDataSource:self];
    [self.settingsTable setBackgroundColor:[UIColor clearColor]];
    [self.settingsTable setSeparatorColor:[UIColor chatwalaBlueLight]];
    [self.settingsTable setScrollEnabled:NO];
    
    [self.versionLabel setText:[NSString stringWithFormat:@"v %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
}

- (void)onSettingsDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom cells

- (UITableViewCell *) tableViewDeliveryMethod:(UITableView *) tableView {
    
    NSString * deliveryMethod = [[CWUserManager sharedInstance] newMessageDeliveryMethod];

    if([deliveryMethod isEqualToString:kNewMessageDeliveryMethodValueSMS]) {
        self.deliveryMethodCell.deliveryMethodSegmentedControl.selectedSegmentIndex = 0;
    }
    else if ([deliveryMethod isEqualToString:kNewMessageDeliveryMethodValueEmail]) {
        self.deliveryMethodCell.deliveryMethodSegmentedControl.selectedSegmentIndex = 1;
    }
    
    [self.deliveryMethodCell setBackgroundColor:[UIColor chatwalaBlueMedium]];
    return self.deliveryMethodCell;
}

- (UITableViewCell *)showMessagePreviewCell:(UITableView *)tableView {

    if([CWUserDefaultsController shouldShowMessagePreview]) {
        self.messagePreviewCell.showMessagePreviewSegmentedControl.selectedSegmentIndex = 1;
    }
    else {
        self.messagePreviewCell.showMessagePreviewSegmentedControl.selectedSegmentIndex = 0;
    }
    
    [self.messagePreviewCell setBackgroundColor:[UIColor chatwalaBlueMedium]];
    return self.messagePreviewCell;
}

#pragma mark - Table view delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == ToggleMessageDeliveryMethodIndex)
    {
        return [self tableViewDeliveryMethod:tableView];
    }
    else if (indexPath.row == ToggleShowMessagePreviewIndex) {
        return [self showMessagePreviewCell:tableView];
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    [cell setBackgroundColor:[UIColor chatwalaBlueMedium]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 80.0f)];
    [bgview setBackgroundColor:[UIColor chatwalaRed]];
    [cell setSelectedBackgroundView:bgview];
    [cell.textLabel setText:[[@[self.section1Titles]objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    if (indexPath.section == 0 && (indexPath.row != MarkAllMessagesAsReadIndex || indexPath.row != ClearFileSpaceIndex)) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = 0;
    if (section == 0) {
        count = [self.section1Titles count] + 2;
    }
    else if (section == 1) {
        count = 6;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat h = 0.0f;
    if (section==0) {
        h= 64.0f;
    }
    if (section==1) {
        h= 40.0f;
    }
    return h;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            // section 1
        {
            switch (indexPath.row) {
                case 0:
                {
                    CWTermsViewController* tocVC = [[CWTermsViewController alloc] init];
                    [self.navigationController pushViewController:tocVC animated:YES];
                }
                    break;
                case 1:
                {
                    CWPrivacyViewController* privVC = [[CWPrivacyViewController alloc] init];
                    [self.navigationController pushViewController:privVC animated:YES];
                }
                    break;
                case 2:
                {
                    UIViewController * viewController = [[CWProfilePictureViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                case 3:
                    // Mark all messages as read
                    [NC postNotificationName:CWNotificationShouldMarkAllMessagesAsRead object:nil];
                    break;
                case 4:
                    [[CWMessageManager sharedInstance] clearDiskSpace];
                default:
                {
                    
                }
                    break;
            }
        }
            break;
            
        case 1:
            // section 2
        {
            
        }
            break;
            
        default:
            break;
    }
}

@end