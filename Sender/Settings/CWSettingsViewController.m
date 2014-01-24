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
#import "CWFeedBackViewController.h"
#import "CWGroundControlManager.h"
#import "CWProfilePictureViewController.h"
#import "UIColor+Additions.h"

@interface CWSettingsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (nonatomic,strong) NSArray * sectionHeaders;
@property (nonatomic,strong) NSArray * section1Titles;
@property (nonatomic,strong) NSArray * section2Titles;
@end

@implementation CWSettingsViewController

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
    UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSettingsDone)];
    
    [self.navigationItem setRightBarButtonItem:doneBtn];
    [self.navigationItem setTitle:@"SETTINGS"];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    

    [self setSectionHeaders:@[@"",@""]];
//    [self setSection2Titles:@[@"Push Notification"]];
    NSDictionary * att = @{
                           NSForegroundColorAttributeName: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]
                           };
    [self.navigationController.navigationBar setTitleTextAttributes:att];
    
    
    [self setSection1Titles:@[@"Terms and Conditions",@"Privacy Policy",@"Feedback", @"Edit Your Profile Picture"]];
    
    [self.settingsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"settingsCell"];
    [self.settingsTable setDelegate:self];
    [self.settingsTable setDataSource:self];
    [self.settingsTable setBackgroundColor:[UIColor clearColor]];
    [self.settingsTable setSeparatorColor:[UIColor chatwalaBlueLight]];
    [self.settingsTable setScrollEnabled:NO];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)onSettingsDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    [cell setBackgroundColor:[UIColor chatwalaBlueMedium]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    UIView* bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
    [bgview setBackgroundColor:[UIColor chatwalaRed]];
    [cell setSelectedBackgroundView:bgview];
    [cell.textLabel setText:[[@[self.section1Titles]objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    if (indexPath.section == 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == 0) {
        count = [self.section1Titles count];
    }else if (section == 1)
    {
        count = 4;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat h;
    if (section==0) {
        h= 64;
    }
    if (section==1) {
        h= 40;
    }
    return h;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
                    CWFeedBackViewController* tocVC = [[CWFeedBackViewController alloc] init];
                    [self.navigationController pushViewController:tocVC animated:YES];
//                    if ([MFMailComposeViewController canSendMail]) {
//                        MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
//                        [mailComposer setMailComposeDelegate:self];
//                        [mailComposer setSubject:[[CWGroundControlManager sharedInstance] feedbackEmailSubject]];
//                        [mailComposer setMessageBody:[[CWGroundControlManager sharedInstance] feedbackEmailBody] isHTML:NO];
//                        [mailComposer setToRecipients:@[@"hello@chatwala.com"]];
//                        [self presentViewController:mailComposer animated:YES completion:nil];
//                    }
                }
                    break;
                case 3:
                {
                    UIViewController * viewController = [[CWProfilePictureViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
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

//#pragma mark MFMailComposeViewControllerDelegate
//
//- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    [controller dismissViewControllerAnimated:YES completion:nil];
//}


@end
