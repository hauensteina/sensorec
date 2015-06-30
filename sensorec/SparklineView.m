//
//  SparklineView.m
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import "SparklineView.h"
#import "AutolayoutUtils.h"

@interface SparklineView ()
@property(strong, nonatomic) NSString* label;
@property(strong, nonatomic) SparklinePlotType* plotType;
@property(strong, nonatomic, readwrite) NSMutableArray* dataPoints;
@property(weak, nonatomic) UIScrollView* scrollView;
@property(assign, nonatomic) int plotIdx;
@end

@implementation SparklineView


-(instancetype) initWithPlotType:(SparklinePlotType*) plotType
                     withPlotIdx:(int)idx{
    self = [SparklineView new];
    if(self){
        _plotType = plotType;
        _label = plotType.metricName;
        _dataPoints = [NSMutableArray new];
        _lastPoint = CGPointZero;
        _plotIdx =idx;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    if(self.dataPoints.count < 2)
        return;
    CGContextRef ref = UIGraphicsGetCurrentContext();
    NSNumber* val = self.dataPoints.firstObject;
    CGFloat height =  self.bounds.size.height;
    CGFloat y = height - [self calculateY:val];
    CGFloat x = 0;
    CGContextMoveToPoint(ref, x, y);
    for(long i=1; i<self.dataPoints.count; i++){
        val = self.dataPoints[i];
        x = x + PITCH;
        y = height - [self calculateY:val];
        CGContextAddLineToPoint(ref, x, y);
        if(i == self.dataPoints.count-1){
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            self.lastPoint = CGPointMake(x-screenWidth, 0);
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"scrolling to plot:%d x:%f y:%f", self.plotIdx,
//                      self.lastPoint.x, self.lastPoint.y);
                [self.scrollView setContentOffset:[self.scrollView
                                                   convertPoint:self.lastPoint
                                                   fromView:self] animated:NO];
            });
        }
    }
    CGContextSetLineWidth(ref, 1);
    CGContextSetStrokeColorWithColor(ref, self.plotType.color.CGColor);
    CGContextStrokePath(ref);
}

-(CGFloat)calculateY:(NSNumber*) value{
    if(value.floatValue == 0.0)
        return 0;
//    if(value.floatValue >= self.plotType.maxValue.floatValue)
//        return (self.bounds.size.height-5)/self.plotType.maxValue.floatValue;
//    else
//        return (self.bounds.size.height-5)/value.floatValue;
    if(value.floatValue >= self.plotType.maxValue.floatValue)
        return (self.bounds.size.height-5);
    else
        return (self.bounds.size.height-5)*value.floatValue
        /self.plotType.maxValue.floatValue;

}

-(void) plotDataPointWithValue:(NSNumber*) value{
    NSLog(@"plot:%d plotDataPointWithValue:%@", self.plotIdx, value);
    [_dataPoints addObject:value];
    [self setNeedsDisplay];
}

-(void)doLayout:(UIScrollView*) sv{
    self.scrollView = sv;
    UILabel* label= [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%@:%d",self.label, self.plotIdx];
    [self addSubview:label];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:0
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:0
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1 constant:0]];
}


@end
