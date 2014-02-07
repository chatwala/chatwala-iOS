#import "_MyOtherEntity.h"

@protocol MyOtherEntity <_MyOtherEntity>
@end

@interface MyOtherEntity : _MyOtherEntity <MyOtherEntity> {}
// Custom logic goes here.
@end
