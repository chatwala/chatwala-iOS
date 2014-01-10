#import "_User.h"

@protocol User <_User>
@end

@interface User : _User <User> {}
// Custom logic goes here.

- (NSOrderedSet *) inboxMessages;

@end
