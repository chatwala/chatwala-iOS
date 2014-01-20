#import "User.h"
#import "Message.h"

@interface User ()

// Private interface goes here.

@end


@implementation User

// Custom logic goes here.

- (NSOrderedSet *) inboxMessages
{
    //
    NSMutableOrderedSet * messages = [NSMutableOrderedSet orderedSetWithOrderedSet:self.messagesReceived];
    
    NSMutableIndexSet * removeObjects = [[NSMutableIndexSet alloc]init];
    for (NSInteger index = 0; index < messages.count; ++index) {
        Message * message = [messages objectAtIndex:index];
        NSAssert([message isKindOfClass:[Message class]], @"expecting message objects. found %@",message);
        if(eMessageDownloadStateDownloaded != message.eDownloadState)
        {
            [removeObjects addIndex:index];
        }
    }
    [messages removeObjectsAtIndexes:removeObjects];
    
    [messages sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        Message * message1 = obj1;
        Message * message2 = obj2;
        
        return [message2.timeStamp compare:message1.timeStamp];
    }];
    
    return messages;
}

- (NSInteger) numberOfUnreadMessages
{
    NSInteger count = 0;
    for (Message * item in self.messagesReceived) {
        switch (item.eMessageViewedState) {
            case eMessageViewedStateUnOpened:
                count++;
                break;
            default:
                break;
        }
    }
    return count;
}



@end
