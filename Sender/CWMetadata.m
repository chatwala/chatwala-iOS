//
//  CWMetadata.m
//  Sender
//
//  Created by Khalid on 11/7/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMetadata.h"

@implementation CWMetadata


- (instancetype)init
{
    self= [super init];
    if (self) {
        NSLog(@"new metadata object");
    }
    return self;
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"timestamp": @"timestamp",
             @"versionId": @"version_id",
             @"senderId": @"sender_id",
             @"recipientId": @"recipient_id",
             @"threadId": @"thread_id",
             @"threadIndex":@"thread_index",
             @"messageId":@"message_id",
             @"startRecording":@"start_recording"
             };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}


+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end
