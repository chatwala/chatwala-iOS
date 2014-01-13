#import "Message.h"


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

- (void) downloadChatwalaData
{
    
}

@end
