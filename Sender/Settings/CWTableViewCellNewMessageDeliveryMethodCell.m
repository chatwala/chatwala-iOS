//
//  CWTableViewCellNewMessageDeliveryMethodCell.m
//  Sender
//
//  Created by randall chatwala on 1/30/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWTableViewCellNewMessageDeliveryMethodCell.h"
#import "CWUserManager.h"

@implementation CWTableViewCellNewMessageDeliveryMethodCell

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

- (IBAction)deliveryMethodChanged:(id)sender {
    
    switch (self.deliveryMethodSegmentedControl.selectedSegmentIndex) {
        case 0:
            [[CWUserManager sharedInstance] setNewMessageDeliveryMethod:kNewMessageDeliveryMethodValueSMS];
            break;
        case 1:
            [[CWUserManager sharedInstance] setNewMessageDeliveryMethod:kNewMessageDeliveryMethodValueEmail];
            break;
        default:
            break;
    }
}

@end
