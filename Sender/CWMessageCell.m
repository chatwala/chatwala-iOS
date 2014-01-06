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


@interface CWMessageCell ()
@property (nonatomic,strong) UIView * cellView;
@end


@implementation CWMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 80)];
        [self.thumbView setContentMode:UIViewContentModeCenter];
        self.thumbView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.thumbView];
        
        self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];;
        [self.spinner setTintColor:[UIColor redColor]];
        [self.spinner setHidesWhenStopped:YES];
        [self.spinner startAnimating];
        
        self.accessoryView = self.spinner;
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

- (void)setMessageData:(NSDictionary*)data
{
    NSURL * imageURL = [NSURL URLWithString:[data objectForKey:@"thumbnail"]];
    if(([imageURL isEqual:self.imageURL]) && (self.imageURL != nil))
    {
        return;//exit early because we are already there.
    }
       
    [self.spinner startAnimating];
    
    UIImage *placeholder = [UIImage imageNamed:@"message_thumb"];
    NSMutableURLRequest * imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
    
    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:imageURLRequest];
    
    [self.thumbView setImageWithURLRequest:imageURLRequest placeholderImage:placeholder success:self.successImageDownloadBlock failure:self.failureImageDownloadBlock];


}

- (AFNetworkingSuccessBlock) successImageDownloadBlock
{
    return (^ void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"message thumbnail Response: %@", response);
        self.thumbView.image = image;
        self.imageURL = request.URL;
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
