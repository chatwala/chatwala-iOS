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
@property (nonatomic,strong) UIActivityIndicatorView * spinner;
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

- (UIActivityIndicatorView *)spinner
{
    if (_spinner == nil) {
        _spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setTintColor:[UIColor redColor]];
        [_spinner setFrame:CGRectMake(0, 0, 40, 40)];
        [_spinner startAnimating];
    }
    
    return _spinner;
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self setAccessoryView:self.spinner];
    }else{
        [self setAccessoryView:nil];
    }
}

- (void)prepareForReuse
{
    [self.progressView setHidden:YES];
    [self setAccessoryView:nil];
    
}

- (void)setMessageData:(NSDictionary*)data
{
    NSURL * imageURL = [NSURL URLWithString:[data valueForKey:@"thumbnail"]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage * image = [UIImage imageWithData:imageData];
    [self.thumbView setImage:image];
}


@end
