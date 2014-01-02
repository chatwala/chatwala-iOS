//
//  CWMessageCell.h
//  Sender
//
//  Created by Khalid on 12/23/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AFNetworkingSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFNetworkingFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface CWMessageCell : UITableViewCell
- (void)setMessageData:(NSDictionary*)data;
@property (nonatomic,strong) UIImageView * thumbView;
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,strong) UIActivityIndicatorView * spinner;
@property (nonatomic, strong) NSURL * imageURL;

@property (strong, readonly) AFNetworkingSuccessBlock successImageDownloadBlock;
@property (strong, readonly) AFNetworkingFailureBlock failureImageDownloadBlock;
@end
