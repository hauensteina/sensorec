//
//  SparklineContainerView.h
//  SparklineApp
//
//  Created by Niladri Bora on 6/25/15.
//  Copyright (c) 2015 LUMO Bodytech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SparklinePlotType : NSObject

@property(strong, nonatomic) NSString* metricName;
@property(strong, nonatomic) NSNumber* maxValue;
@property(strong, nonatomic) UIColor* color;

+(instancetype) newWithMetricName:(NSString*) name
                         maxValue:(NSNumber*) maxValue
                            color:(UIColor*) color;

@end


@interface SparklineContainerView : UIView

-(instancetype) initWithPlotTypes:(NSArray*) plotTypes;

-(void) doLayout:(id<UIScrollViewDelegate>) delegate;

-(void) addTile;

-(void) plotPoints:(NSDictionary*) points;
@end
