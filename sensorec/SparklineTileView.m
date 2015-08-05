//
//  SparklineTileView.m
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import "SparklineTileView.h"
#import "SparklineView.h"
#import "AutolayoutUtils.h"

@interface SparklineTileView ()

@property(assign, nonatomic) long numGraphs;
@property(strong, nonatomic) NSArray* plotTypes;
@property(strong, nonatomic) NSMutableDictionary* viewMap;
@property(strong, nonatomic, readwrite) NSMutableArray* dataPoints;
@property(weak, nonatomic) UIScrollView* scrollView;
@property(weak, nonatomic) SparklineContainerView* containerView;
@property(assign, nonatomic) int tileIdx;
@end

@implementation SparklineTileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype) initWithPlotTypes:(NSArray*) plotTypes
                      withTileIdx:(long) tileIdx{
    self = [SparklineTileView new];
    if(self){
        _numGraphs = plotTypes.count;
        _plotTypes = plotTypes;
        _sparklineViews = [NSMutableArray new];
        _viewMap =  [NSMutableDictionary new];
        _dataPoints = [NSMutableArray new];
        _tileIdx = tileIdx;
    }
    return self;
}

/**
 @param points a dictionary of key-values  where key=metric name, value= value for
 the metric
 */
-(void) plotPoints:(NSDictionary*) points{
    for(NSString* metricName in points){
        [((SparklineView*)self.viewMap[metricName])
         plotDataPointWithValue:(NSNumber*)points[metricName]];
    }
    [self.dataPoints addObject:points];
}

//-(BOOL) isAtMaxCapacity{
//    SparklineView* v = (SparklineView*)self.viewMap[self.viewMap.allKeys[0]];
//    if(v.dataPoints.count <= PLOT_WIDTH/PITCH)
//        return NO;
//    else
//        return YES;
//}

-(void) doLayout:(UIScrollView*) sv
withContainerView:(SparklineContainerView*) containerView{
    self.scrollView = sv;
    self.containerView = containerView;
    SparklineView* firstView = [[SparklineView alloc]
                                initWithPlotType:(SparklinePlotType*)self.plotTypes[0]
                                withPlotIdx:self.tileIdx];
    [self.sparklineViews addObject:firstView];
    self.viewMap[((SparklinePlotType*)self.plotTypes[0]).metricName] = firstView;
    firstView.translatesAutoresizingMaskIntoConstraints = NO;
    firstView.backgroundColor = [UIColor clearColor];
    [self addSubview:firstView];
    [firstView doLayout:sv withContainer:containerView];
    [self addConstraints:
     VF_CONSTRAINT([NSString stringWithFormat:@"H:|[firstView(%ld)]|", [SparklineView maxWidth]],
                   nil,
                   NSDictionaryOfVariableBindings(firstView))];
    [self addConstraints:VF_CONSTRAINT(@"V:|[firstView]", nil,
                                       NSDictionaryOfVariableBindings(firstView))];
    SparklineView* lastView =  firstView;
    if(self.numGraphs>1){
        for(int i=2; i <= self.numGraphs;i++ ){
            SparklineView* nextView = [[SparklineView alloc]
                                       initWithPlotType:(SparklinePlotType*)self.plotTypes[i-1]
                                       withPlotIdx:self.tileIdx];
            [self.sparklineViews addObject:nextView];
            self.viewMap[((SparklinePlotType*)self.plotTypes[i-1]).metricName] = nextView;
            nextView.translatesAutoresizingMaskIntoConstraints = NO;
            nextView.backgroundColor = [UIColor clearColor];
            [self addSubview:nextView];
            [nextView doLayout:self.scrollView withContainer:self.containerView];
            [self addConstraints:
             VF_CONSTRAINT([NSString stringWithFormat:@"H:|[nextView(%ld)]|", [SparklineView maxWidth]], nil,
                                               NSDictionaryOfVariableBindings(nextView))];
            [self addConstraints:VF_CONSTRAINT(@"V:[lastView][nextView]", nil,
                                               NSDictionaryOfVariableBindings(lastView, nextView))];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:nextView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:0
                                                                toItem:lastView
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1 constant:0]];
            lastView = nextView;
        }
    }
    else{
        [self addConstraint:[NSLayoutConstraint constraintWithItem:lastView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:0
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1 constant:0]];
    }
    [self addConstraints:VF_CONSTRAINT(@"V:[lastView]|", nil,
                                       NSDictionaryOfVariableBindings(lastView))];
//    [sv.superview addConstraint:[NSLayoutConstraint constraintWithItem:lastView
//                                                             attribute:NSLayoutAttributeBottom
//                                                             relatedBy:0
//                                                                toItem:sv.superview
//                                                             attribute:NSLayoutAttributeBottom
//                                                            multiplier:1 constant:0]];
}


@end
