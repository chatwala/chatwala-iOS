#import "User.h"


@interface User ()

// Private interface goes here.

@end


@implementation User

// Custom logic goes here.

- (NSOrderedSet *) inboxMessages
{
    return self.messagesReceived;
}

@end
