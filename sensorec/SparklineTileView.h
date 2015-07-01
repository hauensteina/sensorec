//
//  SparklineTileView.h
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SparklineContainerView.h"

@interface SparklineTileView : UIView

@property(strong, nonatomic, readonly) NSMutableArray* dataPoints;
@property(strong, nonatomic) NSMutableArray* sparklineViews;

-(void) doLayout:(UIScrollView*) sv
withContainerView:(SparklineContainerView*) containerView;

-(instancetype) initWithPlotTypes:(NSArray*) plotTypes
                      withTileIdx:(long) tileIdx;

-(void) plotPoints:(NSDictionary*) points;

//-(BOOL) isAtMaxCapacity;

@end
