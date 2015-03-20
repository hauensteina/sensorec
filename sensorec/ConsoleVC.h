//
//  ConsoleVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-03-17.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsoleVC : UIViewController
<UITextFieldDelegate, UITextViewDelegate>

- (void) pr:(NSArray *)keys
     values:(NSArray *)values
        num:(int)num;
- (void) pr:(NSString *)str
      color:(UIColor *)color;
- (void) pr:(NSString *)str
      color:(UIColor *)color
        num:(int)num;
- (void) pr:(NSString *)str;


@end
