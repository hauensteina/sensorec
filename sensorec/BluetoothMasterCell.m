//
//  BluetoothMasterCell.m
//  Sensoplex
//
//  Created by Maciej Czupryna on 08.11.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import "common.h"
#import "BluetoothMasterCell.h"
//#import "UIView+Addons.h"

#define COLOR_GRAY_BORDER RGB(0xa4a4a4)
#define COLOR_DARK_GRAY_TEXT RGB(0x353535)

//====================================
@implementation BluetoothMasterCell
//====================================
{
    UIView *_bordersContentView;
}

//------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
//------------------------------------------------
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _label1 = [self label];
        [self.contentView addSubview:_label1];
        
        _label2 = [self label];
        [self.contentView addSubview:_label2];
        
        _label3 = [self label];
        [self.contentView addSubview:_label3];
        
        _label4 = [self label];
        [self.contentView addSubview:_label4];
        
        self.drawBorder = YES;
        self.borderColor = COLOR_GRAY_BORDER;
        
        _bordersContentView = [[UIView alloc] init];
        [_bordersContentView setBackgroundColor:[UIColor clearColor]];
        [_bordersContentView setUserInteractionEnabled:NO];
        [_bordersContentView setClipsToBounds:YES];
        [self.contentView addSubview:_bordersContentView];
    
    }
    return self;
}

//------------------------------------------------
- (void)layoutSubviews
//------------------------------------------------
{
    [super layoutSubviews];
    
    CGFloat _label1Ratio = 0.0;
    CGFloat _label2Ratio = 0.6;
    CGFloat _label3Ratio = 0.0;
    CGFloat _label4Ratio = 0.4;
    
    CGRect bounds = self.contentView.bounds;
    CGFloat inset = 10;
    
    CGRect frame = bounds;
    frame.origin.x = inset;
    frame.size.width = roundf(CGRectGetWidth(bounds) * _label1Ratio - inset);
    [_label1 setFrame:frame];
    if(frame.size.width <= 0)
        [_label1 setHidden:YES];
    
    frame.origin.x = CGRectGetMaxX(_label1.frame) + inset;
    frame.size.width = roundf(CGRectGetWidth(bounds) * _label2Ratio - inset);
    [_label2 setFrame:frame];
    if(frame.size.width <= 0)
        [_label2 setHidden:YES];
    
    frame.origin.x = CGRectGetMaxX(_label2.frame) + inset;
    frame.size.width = roundf(CGRectGetWidth(bounds) * _label3Ratio - inset);
    [_label3 setFrame:frame];
    if(frame.size.width <= 0)
        [_label3 setHidden:YES];
    
    frame.origin.x = CGRectGetMaxX(_label3.frame) + inset;
    frame.size.width = roundf(CGRectGetWidth(bounds) * _label4Ratio - inset);
    [_label4 setFrame:frame];
    if(frame.size.width <= 0)
        [_label4 setHidden:YES];
    
    
    // draw borders
    RM_SUBVIEWS(_bordersContentView);
    [_bordersContentView setFrame:bounds];
    
//    if(self.drawBorder)
//    {
//        UIView *v = [[UIView alloc] initWithFrame:CGRectOffset(_bordersContentView.bounds, 0, -1)];
//        [v setBackgroundColor:[UIColor clearColor]];
//        [v.layer setBorderColor:self.borderColor.CGColor];
//        [v.layer setBorderWidth:1];
//        [_bordersContentView addSubview:v];
//    }
    
    CGFloat x = CGRectGetMaxX(_label1.frame);
    CGFloat yMax = CGRectGetMaxY(bounds);
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, yMax)];
    [v setBackgroundColor:self.borderColor];
    [_bordersContentView addSubview:v];
    //if(_label1.isHidden)
        [v setHidden:YES];
    
    x = CGRectGetMaxX(_label2.frame);
    v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, yMax)];
    [v setBackgroundColor:self.borderColor];
    [_bordersContentView addSubview:v];
    //if(_label2.isHidden)
        [v setHidden:YES];
    
    x = CGRectGetMaxX(_label3.frame);
    v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, yMax)];
    [v setBackgroundColor:self.borderColor];
    [_bordersContentView addSubview:v];
    //if(_label3.isHidden)
        [v setHidden:YES];
    
} // layoutSubviews()

#pragma mark - Private methods

//---------------------
- (UILabel*)label
//---------------------
{
    UILabel *l = [[UILabel alloc] init];
    [l setBackgroundColor:[UIColor clearColor]];
    //[l setFont:[AppEngine defaultFontWithSize:13]];
    [l setFont: [UIFont fontWithName:@"HelveticaNeue" size: 20]];
    [l setTextColor:COLOR_DARK_GRAY_TEXT];
    return l;
}



@end
