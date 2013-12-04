//
//  CWMiddleButton.m
//  Sender
//
//  Created by Khalid on 12/4/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMiddleButton.h"

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
        
        
        
        
        
        DCKnob * knob = [[DCKnob alloc]initWithDelegate:self];
        [knob setFrame:innerRect];
        [knob setBackgroundColor:[UIColor clearColor]];
        [knob setColor:[UIColor colorFromHexString:@"#ff6c8d"]];
        [knob setMin:0];
        [knob setMax:1];
        [knob setValue:0.5];
        [knob setBackgroundColorAlpha:0];
        [knob setCutoutSize:0];
        [knob setArcStartAngle:-90];
        [knob setDisplaysValue:NO];
        [knob setValueArcWidth:innerRect.size.width*0.5];
        [self addSubview:knob];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    }
    return self;
}

- (void)controlValueDidChange:(float)value sender:(id)sender
{
    
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
