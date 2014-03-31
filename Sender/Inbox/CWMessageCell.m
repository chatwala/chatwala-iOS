//
//  CWMessageCell.m
//  Sender
//
//  Created by k on 12/20/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMessageCell.h"
#import "CWUserManager.h"
#import "UIColor+Additions.h"
#import "CWMessageManager.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "CWConstants.h"

@interface CWMessageCell ()
@property (nonatomic,strong) UIView * cellView;
@property (nonatomic, strong) UIImageView * statusImage;
@property (nonatomic, strong) UILabel * sentTimeLabel;
@end


@implementation CWMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.thumbView  = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 131.0f, 72.0f)];
        [self.thumbView setContentMode:UIViewContentModeCenter];
        self.thumbView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbView.clipsToBounds = YES;
        [self addSubview:self.thumbView];
        
        self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];;
        [self.spinner setTintColor:[UIColor redColor]];
        [self.spinner setHidesWhenStopped:YES];
        [self.spinner startAnimating];
        
        self.accessoryView = self.spinner;
        
        UIView * border = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 131.0f, 2.0f)];
        border.backgroundColor = [UIColor chatwalaBlueDark];
        [self addSubview:border];
        
        UIImageView * gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient"]];
        gradient.frame = CGRectMake(CGRectGetMaxX(self.thumbView.bounds) - gradient.bounds.size.width, 0, gradient.bounds.size.width, CGRectGetHeight(self.thumbView.bounds));
        [gradient setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:gradient];
        
        
        self.statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redDot"]];
        self.statusImage.center = CGPointMake(CGRectGetMaxX(self.thumbView.bounds) - 9 - self.statusImage.bounds.size.width/2, CGRectGetMidY(self.thumbView.bounds) - 1);
        [self addSubview:self.statusImage];

        const CGFloat fontSize = 14.0f;
        CGRect labelFrame =CGRectMake(0.0f, CGRectGetMaxY(self.statusImage.frame) - fontSize + 2, CGRectGetMinX(self.statusImage.frame) - 6, fontSize);
        
        self.sentTimeLabel = [[UILabel alloc] initWithFrame:labelFrame];
        self.sentTimeLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:fontSize];
        self.sentTimeLabel.textAlignment = NSTextAlignmentRight;
        self.sentTimeLabel.textColor = [UIColor chatwalaSentTimeText];
        
        [self addSubview:self.sentTimeLabel];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.spinner stopAnimating];
    [self.sentTimeLabel setText:@""];
}

+ (NSString *)cellIdentifier {
    return @"messageCell";
}

- (void)setMessage:(Message *) message {
    
    [self fetchThumbnailForMessage:message];
    
    NSString * timeValue = [self timeStringFromDate:message.timeStamp];
    self.sentTimeLabel.text = timeValue;
}

- (void)fetchThumbnailForMessage:(Message *)message {
    
    NSURL * imageURL = [self thumbnailURLFromMessage:message];
    [self.spinner startAnimating];
    
    UIImage *placeholder = [UIImage imageNamed:@"message_thumb"];
    NSMutableURLRequest * imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
    
    [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:imageURLRequest];
    
    SDWebImageDownloader *manager = [SDWebImageManager sharedManager].imageDownloader;
    [manager setValue:[NSString stringWithFormat:@"%@:%@", CWConstantsChatwalaAPIKey, CWConstantsChatwalaAPISecret] forHTTPHeaderField:CWConstantsChatwalaAPIKeySecretHeaderField];
    
    __block CWMessageCell *blockSelf = self;
    
    [self.thumbView setImageWithURL:imageURL placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        [blockSelf.spinner stopAnimating];
        
        if (error) {
            NSLog(@"Error fetching image from URL:  %@", imageURL);
        }
        else {
            
            // Default to a fresh web image
            NSString *cacheTypeString = @"blob storage.";
            
            if (cacheType == SDImageCacheTypeDisk) {
                cacheTypeString = @"disk cache.";
            }
            else {
                cacheTypeString = @"memory cache.";
            }
            
            NSLog(@"Successfully fetched image from %@", cacheTypeString);
        }
    }];

}

- (NSURL *)thumbnailURLFromMessage:(Message *)message {
    return [NSURL URLWithString:message.thumbnailPictureURL];
}

- (void)configureStatusFromMessageViewedState:(eMessageViewedState)viewedState {
    
    switch (viewedState) {
        default:
        case eMessageViewedStateRead:
        case eMessageViewedStateOpened:
            self.statusImage.hidden = YES;
            break;
        case eMessageViewedStateUnOpened:
            self.statusImage.image = [UIImage imageNamed:@"redDot"];
            self.statusImage.hidden = NO;
            break;
        case eMessageViewedStateReplied:
            self.statusImage.image = [UIImage imageNamed:@"Icon-Replied"];
            self.statusImage.hidden = NO;
            break;
    }
}

- (NSString *) timeStringFromDate:(NSDate *) timeStamp {

    if(nil == timeStamp) {
        return @"";
    }
    
    NSDate *launchDate = [NSDate dateWithTimeIntervalSince1970:1388534400];//january 1 2014
    
    if([timeStamp isEqual:[timeStamp earlierDate:launchDate]]) {
        return @"";//do not display sent date if its earlier than launch date
    }
   
    NSTimeInterval timeThatHasPassed = -[timeStamp timeIntervalSinceNow];
    
    if(timeThatHasPassed < 0) {
        return @"";//do not display sent date if it is in the future
    }
    
    NSInteger wholeSeconds = timeThatHasPassed;
    
    const NSInteger kSecondsPerMinute = 60;
    const NSInteger kSecondsPerHour = 60 * kSecondsPerMinute;
    const NSInteger kSecondsPerDay = 24 * kSecondsPerHour;
    const NSInteger kSecondsPerWeek = 7 * kSecondsPerDay;
    const NSInteger kSecondsPerYear = 52 * kSecondsPerWeek;
    
    if(wholeSeconds < kSecondsPerMinute)
    {
        return [NSString stringWithFormat:@"%lis", (long)wholeSeconds];
    }
    if(wholeSeconds < kSecondsPerHour)
    {
        return [NSString stringWithFormat:@"%lim", wholeSeconds/kSecondsPerMinute];
    }
    if(wholeSeconds < kSecondsPerDay)
    {
        return [NSString stringWithFormat:@"%lih", wholeSeconds/kSecondsPerHour];
    }
    if(wholeSeconds < kSecondsPerWeek)
    {
        return [NSString stringWithFormat:@"%lid", wholeSeconds/kSecondsPerDay];
    }
    if(wholeSeconds < kSecondsPerYear)
    {
        return [NSString stringWithFormat:@"%liw", wholeSeconds/kSecondsPerWeek];
    }
    return [NSString stringWithFormat:@"%liy", wholeSeconds/kSecondsPerYear];
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
