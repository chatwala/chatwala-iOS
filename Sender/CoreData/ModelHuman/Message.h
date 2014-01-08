#import "_Message.h"

@protocol Message <_Message>
@end

@interface Message : _Message <Message> {}
// Custom logic goes here.
@end
