//
//  CWUserManager.h
//  Sender
//
//  Created by randall chatwala on 12/16/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "User.h"


@interface CWUserManager : NSObject
+ (id)sharedInstance;

@property (nonatomic) AFHTTPRequestSerializer * requestHeaderSerializer;

- (void)addRequestHeadersToURLRequest:(NSMutableURLRequest *) request;

- (BOOL)hasLocalUser;
- (User *)localUser;

- (void)uploadProfilePicture:(UIImage *) thumbnail forUser:(User *) user;
- (BOOL)hasProfilePicture:(User *) user;
- (NSString *) getProfilePictureEndPointForUser:(User *) user;

@end
