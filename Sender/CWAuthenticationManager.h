//
//  CWAuthenticationManager.h
//  Sender
//
//  Created by Khalid on 11/21/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"

@interface CWAuthenticationManager : NSObject
+(instancetype) sharedInstance;
- (GTMOAuth2ViewControllerTouch *)requestAuthentication;
- (BOOL)isAuthenticated;
@end
