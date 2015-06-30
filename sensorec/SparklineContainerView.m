//
//  SparklineContainerView.m
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import "SparklineContainerView.h"
#import "AutolayoutUtils.h"
#import "SparklineTileView.h"

@implementation SparklinePlotType

+(instancetype) newWithMetricName:(NSString*) name
                         maxValue:(NSNumber*) maxValue
                            color:(UIColor*) color{
    SparklinePlotType* inst = [[SparklinePlotType alloc] init];
    inst.metricName = name;
    inst.maxValue = maxValue;
    inst.color = color;
    return inst;
}

@end


@interface SparklineContainerView()
@property(assign, nonatomic) int numViews;
@property(weak, nonatomic) UIScrollView* scrollView;
@property(strong, nonatomic) NSMutableArray* tileViews;
@property(strong, nonatomic) NSArray* rightEdgeConstraints;
@property(strong, nonatomic) NSArray* plotTypes;
@end

@implementation SparklineContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype) initWithPlotTypes:(NSArray*) plotTypes{
    self = [[SparklineContainerView alloc]
            initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self){
        _numViews = (int)plotTypes.count;
        _plotTypes = plotTypes;
        _tileViews = [NSMutableArray new];
        _rightEdgeConstraints = [NSMutableArray new];
    }
    return self;
}

-(void) doLayout:(id<UIScrollViewDelegate>) delegate{
    UIScrollView* sv = [UIScrollView new];
    sv.delegate =  delegate;
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    sv.backgroundColor = [UIColor clearColor];
    [self addSubview:sv];
    [self addConstraints:VF_CONSTRAINT(@"H:|[sv]|", nil, NSDictionaryOfVariableBindings(sv))];
    [self addConstraints:VF_CONSTRAINT(@"V:|[sv]|", nil, NSDictionaryOfVariableBindings(sv))];
    self.scrollView = sv;
}

-(void) plotPoints:(NSDictionary*) points{
    //figure out how whether we need a new tile to plot the latest points
    if(self.tileViews.count == 0){
        [self addTile];
    }
    else if(((SparklineTileView*)self.tileViews.lastObject).isAtMaxCapacity){
        NSDictionary* lastPoint = ((SparklineTileView*)self.tileViews.lastObject)
        .dataPoints.lastObject;
        [self addTile];
        [(SparklineTileView*)self.tileViews.lastObject plotPoints:lastPoint];
    }
    [(SparklineTileView*)self.tileViews.lastObject plotPoints:points];
}

-(void) addTile{
//    SparklineTileView* newTile = [[SparklineTileView alloc]
//                               initWithNumGraphs:self.numViews];
    SparklineTileView* newTile = [[SparklineTileView alloc]
                                  initWithPlotTypes:self.plotTypes
                                  withTileIdx: (int)self.tileViews.count];
    newTile.translatesAutoresizingMaskIntoConstraints = NO;
    newTile.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:newTile];
    [newTile doLayout:self.scrollView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:newTile
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:0
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1 constant:-20/*top margin*/]];
    [self.scrollView addConstraints:VF_CONSTRAINT(@"V:|-20-[newTile]|", nil,
                                                  NSDictionaryOfVariableBindings(newTile))];
    NSUInteger currSize = self.tileViews.count;
    if(currSize){
        [self.scrollView removeConstraints:self.rightEdgeConstraints];
        //[NSLayoutConstraint deactivateConstraints:self.rightEdgeConstraints];
        SparklineTileView* lastTile = self.tileViews[currSize-1];
        [self.scrollView addConstraints:VF_CONSTRAINT(@"H:[lastTile][newTile]", nil,
                                                      NSDictionaryOfVariableBindings(newTile, lastTile))];
        //[self.scrollView addConstraints:self.rightEdgeConstraints];
    }
    else{
        [self.scrollView addConstraints:VF_CONSTRAINT(@"H:|[newTile]", nil
                                                      , NSDictionaryOfVariableBindings(newTile))];
    }
    self.rightEdgeConstraints = VF_CONSTRAINT(@"H:[newTile]|", nil
                                              , NSDictionaryOfVariableBindings(newTile));
    [self.scrollView addConstraints:self.rightEdgeConstraints];
    [self.tileViews addObject:newTile];
}










@end
