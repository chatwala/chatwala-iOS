//
//  CWTableViewShowMessagePreviewCell.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 2/25/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWTableViewShowMessagePreviewCell.h"

@implementation CWTableViewShowMessagePreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)showMessagePreviewChanged:(id)sender {
    
    switch (self.showMessagePreviewSegmentedControl.selectedSegmentIndex) {
        case 0:
            //[[CWUserManager sharedInstance] setNewMessageDeliveryMethod:kNewMessageDeliveryMethodValueSMS];
            break;
        case 1:
            //[[CWUserManager sharedInstance] setNewMessageDeliveryMethod:kNewMessageDeliveryMethodValueEmail];
            break;
        default:
            break;
    }
}

@end
