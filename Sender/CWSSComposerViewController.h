//
//  CWSSComposerViewController.h
//  Sender
//
//  Created by Khalid on 11/18/13.
//  Copyright (c) 2013 pho. All rights reserved.
//

#import "CWComposerViewController.h"

@interface CWSSComposerViewController : CWComposerViewController
//@property (nonatomic,weak) IBOutlet UIButton * middleButton;

@property (nonatomic,weak) IBOutlet UILabel *recordMessageLabel;

@property (nonatomic) NSString *recipientID;
@property (nonatomic) UIImage *recipientPicture;

@end
