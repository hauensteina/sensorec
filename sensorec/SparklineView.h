//
//  SparklineView.h
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SparklineContainerView.h"
//#define PLOT_WIDTH 600
#define PITCH 5


@interface SparklineView : UIView

-(instancetype) initWithPlotType:(SparklinePlotType*) plotType
                     withPlotIdx:(int)idx;

-(void) doLayout:(UIScrollView*) sv
   withContainer:(SparklineContainerView*) containerView;

-(void) plotDataPointWithValue:(NSNumber*) value;

+(long) maxWidth;

@property(strong, nonatomic, readonly) NSMutableArray* dataPoints;
@property(assign, nonatomic) CGPoint lastPoint;
@property(weak, nonatomic) UILabel* label;

@end
