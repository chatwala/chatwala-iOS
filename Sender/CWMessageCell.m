//
//  CWMessageCell.m
//  Sender
//
//  Created by Khalid on 12/23/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageCell.h"

@interface CWMessageCell ()
@property (nonatomic,strong) UIImageView *thumbView;
@property (nonatomic,strong) UILabel * timeLabel;
@end

@implementation CWMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
        [self.thumbView setContentMode:UIViewContentModeCenter];
        [self addSubview:self.thumbView];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageData:(NSDictionary *)data
{
    [self.thumbView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[data valueForKey:@"thumbnail"]]]]];
}


@end
