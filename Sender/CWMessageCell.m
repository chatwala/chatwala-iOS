//
//  CWMessageCell.m
//  Sender
//
//  Created by k on 12/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageCell.h"


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
//    [self.spinner stopAnimating];
}

- (void)setMessageData:(NSDictionary*)data
{
    [self.thumbView setImage:[UIImage imageNamed:@"message_thumb"]];
    [self.spinner startAnimating];

    NSURL * imageURL = [NSURL URLWithString:[data valueForKey:@"thumbnail"]];
    
    AFHTTPRequestOperation *imageDownloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:imageURL]];
    imageDownloadOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [imageDownloadOperation setCompletionBlockWithSuccess:self.successImageDownloadBlock failure:self.failureImageDownloadBlock];
    [imageDownloadOperation start];

}

- (AFNetworkingSuccessBlock) successImageDownloadBlock
{
    return (^ void(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"message thumbnail Response: %@", responseObject);
        self.thumbView.image = responseObject;
        [self.spinner stopAnimating];
    });
}

- (AFNetworkingFailureBlock) failureImageDownloadBlock
{
    return (^ void(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"message thumbnail Image error: %@", error);
        [self.spinner stopAnimating];
    });
}

@end
