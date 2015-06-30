//
//  SparklineTileView.h
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SparklineTileView : UIView

@property(strong, nonatomic, readonly) NSMutableArray* dataPoints;

-(void) doLayout:(UIScrollView*) sv;

-(instancetype) initWithPlotTypes:(NSArray*) plotTypes
                      withTileIdx:(int) tileIdx;

-(void) plotPoints:(NSDictionary*) points;

-(BOOL) isAtMaxCapacity;

@end
