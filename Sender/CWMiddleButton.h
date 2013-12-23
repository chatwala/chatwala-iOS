//
//  CWMiddleButton.h
//  Sender
//
//  Created by Khalid on 12/4/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    eButtonStateDefault,
    eButtonStateStop,
    eButtonStateShare,
    eButtonStatePlay,
    eButtonStateRecord,
    eButtonStateBusy
}MiddleButtonState;


@interface CWMiddleButton : UIView <DCControlDelegate>
@property (nonatomic,strong) UIButton * button;
- (void)setMinValue:(CGFloat)minValue;
- (void)setMaxValue:(CGFloat)maxValue;
- (void)setValue:(CGFloat)value;
- (void)setButtonState:(MiddleButtonState)state;
- (MiddleButtonState)buttonState;
@end
