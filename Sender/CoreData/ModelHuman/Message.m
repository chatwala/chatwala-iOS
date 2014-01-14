#import "Message.h"
#import "CWUserManager.h"
#import "CWMessageManager.h"

@interface Message ()

// Private interface goes here.

@end


@implementation Message

// Custom logic goes here.

+ (NSDictionary *) keyLookupTable
{
    return @{
             @"message_id":@"messageID",
             @"recipient_id":@"recipient",
             @"sender_id":@"sender",
             @"thumbnail":@"thumbnailPictureURL",
             @"timestamp":@"timeStamp",
             };
}

- (eMessageDownloadState) eDownloadState
{
    NSInteger value = self.downloadStateValue;
    NSAssert(value < eMessageDownloadStateTotal, @"expecting download state to be less than max enum value");
    NSAssert(value >= eMessageDownloadStateInvalid, @"expecting download state to be less than max enum value");
    return value;
}

- (void) setEMessageDownloadState:(eMessageDownloadState ) eState
{
    self.downloadStateValue = eState;
}

- (void) downloadChatwalaDataWithMessageCell:(CWMessageCell *) messageCell
{
    if(messageCell.thumbView)
    {
        NSURL * imageURL = [NSURL URLWithString:self.thumbnailPictureURL];
        
        UIImage *placeholder = [UIImage imageNamed:@"message_thumb"];
        NSMutableURLRequest * imageURLRequest = [NSMutableURLRequest requestWithURL:imageURL];
        
        [[CWUserManager sharedInstance] addRequestHeadersToURLRequest:imageURLRequest];
        
        [messageCell.thumbView setImageWithURLRequest:imageURLRequest placeholderImage:placeholder success:messageCell.successImageDownloadBlock failure:messageCell.failureImageDownloadBlock];
    }
    
    [[CWMessageManager sharedInstance] downloadMessageWithID:self.messageID progress:nil completion:^(BOOL success, NSURL *url) {
        [NC postNotificationName:@"MessagesLoaded" object:nil userInfo:nil];
    }];
    
}

@end
