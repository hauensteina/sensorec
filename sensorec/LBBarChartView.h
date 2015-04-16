//
//  LBBarChartView.h
//  social
//
//  Created by Andreas Hauenstein on 2014-06-22.
//  Copyright (c) 2014 Lumo BodyTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBBarChartView : UIView

@property float topMargin;
@property NSString *title;
@property float titleSpace;
@property float barHeight;
//@property float barSpace;

// Array of dict
// [{"label":NSString,"color":UIColor,"value":NSNumber}, ...]
@property NSMutableArray *bars;

- (void) addBar:(NSDictionary *) bar atPosition:(int)pos;
- (NSMutableDictionary *)getBar:(NSString *) label;
- (void) rmBar:(NSString *) label;
- (void) setColor:(UIColor *)color
           forBar:(NSString *)label;
- (void) setValue:(NSNumber *)val
           forBar:(NSString *)label;

@end

