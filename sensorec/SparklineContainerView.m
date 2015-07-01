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
#import "SparklineView.h"

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
@property(assign, nonatomic) long numViews;
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
        _numViews = plotTypes.count;
        _plotTypes = plotTypes;
        _tileViews = [NSMutableArray new];
        _rightEdgeConstraints = [NSMutableArray new];
 //       _currValueLabels = [NSMutableArray new];
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
//    else if(((SparklineTileView*)self.tileViews.lastObject).isAtMaxCapacity){
//        NSDictionary* lastPoint = ((SparklineTileView*)self.tileViews.lastObject)
//        .dataPoints.lastObject;
//        [self addTile];
//        [(SparklineTileView*)self.tileViews.lastObject plotPoints:lastPoint];
//    }
    [(SparklineTileView*)self.tileViews.lastObject plotPoints:points];
}

-(void) addTile{
    SparklineTileView* newTile = [[SparklineTileView alloc]
                                  initWithPlotTypes:self.plotTypes
                                  withTileIdx:self.tileViews.count];
    newTile.translatesAutoresizingMaskIntoConstraints = NO;
    newTile.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:newTile];
    [newTile doLayout:self.scrollView withContainerView:self];
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
        //hide labels old tile
        SparklineTileView* lastTile = self.tileViews[currSize-1];
        for(SparklineView* slv in lastTile.sparklineViews){
            slv.label.hidden = YES;
        }
        //Now go ahead and layout new tile
        [self.scrollView removeConstraints:self.rightEdgeConstraints];
        [self.scrollView addConstraints:VF_CONSTRAINT(@"H:[lastTile][newTile]", nil,
                                                      NSDictionaryOfVariableBindings(newTile, lastTile))];
    }
    else{
        //first tile
        [self.scrollView addConstraints:VF_CONSTRAINT(@"H:|[newTile]", nil
                                                      , NSDictionaryOfVariableBindings(newTile))];

//        int plotIdx=-1;
//        for(SparklinePlotType* type in self.plotTypes){
//            plotIdx++;
//            UILabel* label = [UILabel new];
//            label.backgroundColor = [UIColor clearColor];
//            [self.currValueLabels addObject:label];
//            [self addSubview:label];
//            [self addConstraints:VF_CONSTRAINT(@"H:[label]|", nil,
//                                               NSDictionaryOfVariableBindings(label))];
//            SparklineView* sv = ((SparklineView*)newTile.sparklineViews[plotIdx]);
//            [self addConstraint: [NSLayoutConstraint constraintWithItem:label
//                                                              attribute:NSLayoutAttributeTop
//                                                              relatedBy:0
//                                                                 toItem:sv
//                                                              attribute:NSLayoutAttributeTop
//                                                             multiplier:1 constant:0]];
//
//        }
    }
    self.rightEdgeConstraints = VF_CONSTRAINT(@"H:[newTile]|", nil
                                              , NSDictionaryOfVariableBindings(newTile));
    [self.scrollView addConstraints:self.rightEdgeConstraints];
    [self.tileViews addObject:newTile];
}

@end
