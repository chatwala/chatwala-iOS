//
//  CWSettingsViewController.m
//  Sender
//
//  Created by Khalid on 12/26/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWSettingsViewController.h"

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
    
    
    [self setSectionHeaders:@[@"",@""]];
    [self setSection1Titles:@[@"Push Notification"]];
    [self setSection2Titles:@[@"Import Messages",@"Link Accounts",@"Terms and Conditions",@"Privacy Policy"]];
    
    
    
    [self.settingsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"settingsCell"];
    [self.settingsTable setDelegate:self];
    [self.settingsTable setDataSource:self];
    [self.settingsTable setBackgroundColor:[UIColor clearColor]];
}


- (void)onSettingsDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    [cell setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.1]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setText:[[@[self.section1Titles,self.section2Titles]objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    if (indexPath.section == 1) {
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
        count = 1;
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
        h= 66;
    }
    if (section==1) {
        h= 80;
    }
    return h;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
