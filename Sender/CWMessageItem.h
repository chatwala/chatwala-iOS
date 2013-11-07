//
//  CWMessageItem.h
//  Sender
//
//  Created by Khalid on 11/7/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWMetadata.h"
@interface CWMessageItem : NSObject
@property (nonatomic,strong) CWMetadata * metadata;
@property (nonatomic,strong) NSURL * zipURL;
@property (nonatomic,strong) NSURL * videoURL;


//- (id)initWithVideoURL:(NSURL*)videoURL; // for creating new message
//- (id)initWithZipURL:(NSURL*)zipURL; // for opening message
- (void)exportZip;
- (void)extractZip;
@end
