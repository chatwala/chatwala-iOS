//
//  AVURLAsset+Spec.h
//  Sender
//
//  Created by Khalid on 11/12/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVURLAsset (Spec)
- (void)completeWithSuccessKeys:(NSArray *)successKeys failureKeys:(NSArray *)failureKeys;
@end
