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

@end
