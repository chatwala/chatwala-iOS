//
//  CWMessageCell.h
//  Sender
//
//  Created by Khalid on 12/23/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
@class Message;

typedef void (^AFNetworkingSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image);
typedef void (^AFNetworkingFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error);

@interface CWMessageCell : UITableViewCell

+ (NSString *)cellIdentifier;
- (void)setMessage:(Message *) message;
- (void)configureStatusFromMessageViewedState:(eMessageViewedState)viewedState;
- (NSURL *)thumbnailURLFromMessage:(Message *)message;


@property (nonatomic,strong) UIImageView * thumbView;
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,strong) UIActivityIndicatorView * spinner;
@property (nonatomic, assign) BOOL isDeleteModeEnabled;

@property (strong, readonly) AFNetworkingSuccessBlock successImageDownloadBlock;
@property (strong, readonly) AFNetworkingFailureBlock failureImageDownloadBlock;

- (NSString *) timeStringFromDate:(NSDate *) timeStamp;

@end
