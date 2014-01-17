//
//  CWMessageCell.m
//  Sender
//
//  Created by k on 12/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CWUserManager.h"
#import "Message.h"


@interface CWMessageCell ()
@property (nonatomic,strong) UIView * cellView;
@property (nonatomic, strong) UIImageView * statusImage;
@end


@implementation CWMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 131, 80)];
        [self.thumbView setContentMode:UIViewContentModeCenter];
        self.thumbView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.thumbView];
        
        self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];;
        [self.spinner setTintColor:[UIColor redColor]];
        [self.spinner setHidesWhenStopped:YES];
        [self.spinner startAnimating];
        
        self.accessoryView = self.spinner;
        
        UIView * boarder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 131, 2)];
        boarder.backgroundColor = [UIColor chatwalaBlueDark];
        [self addSubview:boarder];
        
        
        self.statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redDot"]];
        self.statusImage.center = CGPointMake(CGRectGetMaxX(self.thumbView.bounds) - 20 - self.statusImage.bounds.size.width/2, CGRectGetMidY(self.thumbView.bounds));
//        [self addSubview:self.statusImage];
        
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.spinner startAnimating];
    }else{
//        [self.spinner stopAnimating];
    }
}

- (void)prepareForReuse
{
    [self.spinner stopAnimating];
}

- (void) setMessage:(Message *) message
{
    NSURL * imageURL = [NSURL URLWithString:message.thumbnailPictureURL];
    [self.spinner startAnimating];
    
    UIImage *placeholder = [UIImage imageNamed:@"message_thumb"];
    NSMutableURLRequest * imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
    
    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:imageURLRequest];
    
    [self.thumbView setImageWithURLRequest:imageURLRequest placeholderImage:placeholder success:self.successImageDownloadBlock failure:self.failureImageDownloadBlock];
    
    switch ([message eMessageViewedState]) {
        case eMessageViewedStateRead:
            self.statusImage.hidden = YES;
            break;
        case eMessageViewedStateOpened:
        case eMessageViewedStateUnOpened:
        case eMessageViewedStateReplied:
        default:
            self.statusImage.hidden = NO;
            break;
    }
}

- (AFNetworkingSuccessBlock) successImageDownloadBlock
{
    return (^ void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"message thumbnail Response: %@", response);
        self.thumbView.image = image;
        [self.spinner stopAnimating];
    });
}

- (AFNetworkingFailureBlock) failureImageDownloadBlock
{
    return (^ void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"message thumbnail Image error: %@", error);
        [self.spinner stopAnimating];
    });
}

@end
