//
//  CWMiddleButton.m
//  Sender
//
//  Created by Khalid on 12/4/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMiddleButton.h"

@interface CWMiddleButton ()
@property (nonatomic,strong) DCKnob * knob;
@end


@implementation CWMiddleButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        CALayer * whiteBG = [CALayer layer];
        [whiteBG setFrame:self.bounds];
        [whiteBG setCornerRadius:self.bounds.size.width*0.5];
        [whiteBG setBackgroundColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] CGColor]];
        [self.layer addSublayer:whiteBG];
        
        
        CGRect innerRect = CGRectInset(self.bounds, 10, 10);
        
        
        CALayer * redBG = [CALayer layer];
        [redBG setFrame:innerRect];
        [redBG setCornerRadius:innerRect.size.width*0.5];
        [redBG setBackgroundColor:[[UIColor colorFromHexString:@"#db013f"] CGColor]];
        [self.layer addSublayer:redBG];
        
        
        
        
        
        self.knob= [[DCKnob alloc]initWithDelegate:self];
        [self.knob setUserInteractionEnabled:NO];
        [self.knob setFrame:innerRect];
        [self.knob setBackgroundColor:[UIColor clearColor]];
        [self.knob setColor:[UIColor colorFromHexString:@"#ff6c8d"]];
        [self.knob setMin:0];
        [self.knob setMax:1];
        [self.knob setValue:0.5];
        [self.knob setBackgroundColorAlpha:0];
        [self.knob setCutoutSize:0];
        [self.knob setArcStartAngle:-90];
        [self.knob setDisplaysValue:NO];
        [self.knob setValueArcWidth:innerRect.size.width*0.5];
        [self addSubview:self.knob];
    }
    return self;
}

- (void)controlValueDidChange:(float)value sender:(id)sender
{
    
}

- (void)setMinValue:(CGFloat)minValue
{
    [self.knob setMin:minValue];
}
- (void)setMaxValue:(CGFloat)maxValue
{
    [self.knob setMax:maxValue];
}
- (void)setValue:(CGFloat)value
{
    [self.knob setValue:value];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
