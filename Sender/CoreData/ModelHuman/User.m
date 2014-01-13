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
    
    [messages sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        Message * message1 = obj1;
        Message * message2 = obj2;
        
        return [message2.timeStamp compare:message1.timeStamp];
    }];
    
    return messages;
}

@end
