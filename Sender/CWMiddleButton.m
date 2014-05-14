//
//  CWMiddleButton.m
//  Sender
//
//  Created by Khalid on 12/4/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWMiddleButton.h"

@interface CWMiddleButton ()
{
    MiddleButtonState _state;
}
@property (nonatomic,strong) DCKnob * knob;
@property (nonatomic,strong) UIImageView * iconImage;
@property (nonatomic,strong) UIActivityIndicatorView * spinner;

@property (nonatomic,strong) CALayer * whiteBG;
@property (nonatomic,strong) CALayer * redBG;
@end


@implementation CWMiddleButton

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self configureButton];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    CGRect innerRect = CGRectInset(self.bounds, 10, 10);
    [self.whiteBG setFrame:self.bounds];
    [self.whiteBG setCornerRadius:self.bounds.size.width*0.5];
    
    [self.redBG setFrame:innerRect];
    [self.redBG setCornerRadius:innerRect.size.width * 0.5f];
    
    [self.knob setFrame:innerRect];
    [self.iconImage setFrame:self.bounds];
    [self.button setFrame:self.bounds];
    [self.spinner setFrame:self.bounds];
}

- (void)controlValueDidChange:(float)value sender:(id)sender
{
    
}

- (void)configureButton {
    [self setBackgroundColor:[UIColor clearColor]];
    self.whiteBG = [CALayer layer];
    
    
    [self.whiteBG setBackgroundColor:[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f] CGColor]];
    [self.layer addSublayer:self.whiteBG];
    
    CGRect innerRect = CGRectInset(self.bounds, 10, 10);
    
    self.redBG = [CALayer layer];
   
    [self.redBG setBackgroundColor:[[UIColor colorFromHexString:@"#db013f"] CGColor]];
    [self.layer addSublayer:self.redBG];
    
    self.knob= [[DCKnob alloc]initWithDelegate:self];
    [self.knob setUserInteractionEnabled:NO];
    [self.knob setBackgroundColor:[UIColor clearColor]];
    [self.knob setColor:[UIColor colorFromHexString:@"#ff6c8d"]];
    [self.knob setMin:0];
    [self.knob setMax:1];
    [self.knob setValue:0];
    [self.knob setBackgroundColorAlpha:0];
    [self.knob setCutoutSize:0];
    [self.knob setArcStartAngle:-90];
    [self.knob setDisplaysValue:NO];
    [self.knob setValueArcWidth:innerRect.size.width*0.5];
    [self addSubview:self.knob];
    
    
    self.iconImage = [[UIImageView alloc]initWithFrame:self.bounds];
    [self.iconImage setBackgroundColor:[UIColor clearColor]];
    [self.iconImage setContentMode:UIViewContentModeCenter];
    [self addSubview:self.iconImage];
    
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self addSubview:self.button];
    
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.spinner startAnimating];
    [self.spinner setHidesWhenStopped:YES];
    [self addSubview:self.spinner];
    
}

- (void)setButtonState:(MiddleButtonState)state
{
    [self.spinner stopAnimating];
    _state = state;
    switch (state) {
        case eButtonStateDefault:
            [self.iconImage setImage:nil];
            break;
        case eButtonStatePlay:
            [self.iconImage setImage:[UIImage imageNamed:@"Button-Icon-Play"]];
            break;
        case eButtonStateStop:
            [self.iconImage setImage:[UIImage imageNamed:@"Button-Icon-Stop"]];
            break;
        case eButtonStateShare:
            [self.iconImage setImage:[UIImage imageNamed:@"Button-Icon-Send"]];
            [self.spinner stopAnimating];
            break;
        case eButtonStateRecord:
            [self.iconImage setImage:[UIImage imageNamed:@"Button-Icon-Record"]];
            break;
        case eButtonStateBusy:
            [self.iconImage setImage:nil];
            [self.spinner startAnimating];
            break;
        default:
            [self setButtonState:eButtonStateDefault];
            break;
    }
}

- (MiddleButtonState)buttonState
{
    return _state;
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
