//
//  CWMessageManager.h
//  Sender
//
//  Created by Khalid on 12/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWMessageManager : NSObject < UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) NSArray * messages;
+(instancetype) sharedInstance;
- (void)getMessages;
@end
