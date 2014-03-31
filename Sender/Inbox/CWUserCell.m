//
//  CWUserCell.m
//  Sender
//
//  Created by Rahul Kumar Sharma on 3/26/14.
//  Copyright (c) 2014 pho. All rights reserved.
//

#import "CWUserCell.h"
#import "CWUserManager.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "CWConstants.h"
#import "Message.h"

@interface CWUserCell ()

@property (nonatomic, strong) UIImageView * statusImage;

@end

@implementation CWUserCell

+ (NSString *)cellIdentifier {
    return @"userCell";
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
            self.statusImage.hidden = YES;
            break;
    }
}

- (NSURL *)thumbnailURLFromMessage:(Message *)message {
    return [NSURL URLWithString:message.userThumbnailURL];
}

@end
