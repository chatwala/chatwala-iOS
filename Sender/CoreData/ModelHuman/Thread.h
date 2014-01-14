#import "_Thread.h"

@protocol Thread <_Thread>
@end

@interface Thread : _Thread <Thread> {}
// Custom logic goes here.
@end
