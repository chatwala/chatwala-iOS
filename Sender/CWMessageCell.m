//
//  CWMessageCell.m
//  Sender
//
//  Created by k on 12/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageCell.h"


@interface CWMessageCell ()
@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic,strong) UIView * cellView;
@property (nonatomic,strong) UIImageView * thumbView;
@end


@implementation CWMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 78, 200, 2)];
        [self.contentView addSubview:self.progressView];
        [self.progressView setHidden:YES];
        
        self.thumbView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
        [self.thumbView setContentMode:UIViewContentModeCenter];
        [self addSubview:self.thumbView];
    }
    return self;
}


- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self.progressView setProgress:_progress];
    
    if (_progress<.9)
    {
        [self.progressView setHidden:NO];
    }
    else
    {
        [self.progressView setHidden:YES];
        [self setAccessoryView:nil];
    }
}



- (void)setMessageData:(NSDictionary*)data
{
    [self.thumbView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[data valueForKey:@"thumbnail"]]]]];
}


@end
