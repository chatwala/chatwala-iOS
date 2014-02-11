//
//  UIColor+Additions.m
//  Sender
//
//  Created by Khalid on 12/4/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)chatwalaRed
{
    return [UIColor colorFromHexString:@"#d70137"];
}


+ (UIColor *)chatwalaBlueDark
{
    return [UIColor colorFromHexString:@"#0c2753"];
}


+ (UIColor *)chatwalaBlueMedium
{
    return [UIColor colorFromHexString:@"#172d50"];
}


+ (UIColor *)chatwalaBlueLight
{
    return [UIColor colorFromHexString:@"#3a4c69"];
}

+ (UIColor *)chatwalaFeedbackLabel
{
    return [UIColor colorFromHexString:@"#ede8e2"];
}

+ (UIColor *)chatwalaSentTimeText
{
    return [UIColor colorFromHexString:@"#e8f2fa"];
}
@end
