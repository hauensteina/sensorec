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
@property(strong, nonatomic) NSString* plotName;
@property(strong, nonatomic) SparklinePlotType* plotType;
@property(strong, nonatomic, readwrite) NSMutableArray* dataPoints;
@property(weak, nonatomic) UIScrollView* scrollView;
@property(assign, nonatomic) int plotIdx;
@property(weak, nonatomic) SparklineContainerView* containerView;
@end

@implementation SparklineView


-(instancetype) initWithPlotType:(SparklinePlotType*) plotType
                     withPlotIdx:(int)idx{
    self = [SparklineView new];
    if(self){
        _plotType = plotType;
        _plotName = plotType.metricName;
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
                [self.scrollView setContentOffset:[self.scrollView
                                                   convertPoint:self.lastPoint
                                                   fromView:self] animated:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                     self.label.text = [NSString stringWithFormat:@"%@: %f",
                                       self.plotName, val.floatValue];
                });
//                //label respositioning
//                CGRect lf = self.label.frame;
//                lf.origin.x = 5;
//                lf = [self convertRect:lf fromView:self.containerView];
//                lf.origin.y = 10;
//                self.label.frame = lf;

            });//end dispatch async
        } //end if last point
    }//end for loop
    CGContextSetLineWidth(ref, 1);
    CGContextSetStrokeColorWithColor(ref, self.plotType.color.CGColor);
    CGContextStrokePath(ref);

    CGContextSetLineWidth(ref, 1);
    CGContextSetStrokeColorWithColor(ref, self.plotType.color.CGColor);
    CGContextMoveToPoint(ref, 0, height);
    CGContextAddLineToPoint(ref, x, height);
    CGContextStrokePath(ref);
}

-(CGFloat)calculateY:(NSNumber*) value{
    if(value.floatValue == 0.0)
        return 0;
    if(value.floatValue >= self.plotType.maxValue.floatValue)
        return (self.bounds.size.height-5);
    else
        return (self.bounds.size.height-5)*value.floatValue
        /self.plotType.maxValue.floatValue;

}

-(void) plotDataPointWithValue:(NSNumber*) value{
    NSLog(@"plot:%d plotDataPointWithValue:%@", self.plotIdx, value);
    long width = [SparklineView maxWidth];
    long cnt = width/PITCH;
    while (self.dataPoints.count>=cnt) {
        [self.dataPoints removeObjectAtIndex:0];
    }
    [_dataPoints addObject:value];
    [self setNeedsDisplay];
}

+(long) maxWidth{
    return (long)UIScreen.mainScreen.bounds.size.width*3;
}

-(void)doLayout:(UIScrollView*) sv
  withContainer:(SparklineContainerView*) containerView{
    self.scrollView = sv;
    self.containerView = containerView;
    UILabel* label= [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
//                                                     attribute:NSLayoutAttributeCenterX
//                                                     relatedBy:0
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeCenterX
//                                                    multiplier:1 constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
//                                                     attribute:NSLayoutAttributeCenterY
//                                                     relatedBy:0
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeCenterY
//                                                    multiplier:1 constant:0]];

  
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:0
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1 constant:5]];
    [self addConstraints:VF_CONSTRAINT(@"V:|-5-[label]", nil, NSDictionaryOfVariableBindings(label))];
    self.label = label;
}


@end
