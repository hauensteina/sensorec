//
//  BlurpVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-06-30.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "BlurpVC.h"
#import "SparklineContainerView.h"
#import "common.h"
#import "AutolayoutUtils.h"
#import "SparklineTileView.h"
#import "SparklineView.h"

#define CADENCE @"Cadence"
#define BOUNCE @"Bounce"
#define LURCH @"Lurch"
#define PLOD @"Plod"
#define ROTX @"Rotx"
#define ROTY @"Roty"
#define ROTZ @"Rotz"

#define AVG_SAMPLE_SIZE 5
#define CADENCE_MIN 0
#define CADENCE_MAX 0
#define BOUNCE_MIN 0
#define BOUNCE_MAX 20
#define LURCH_MIN 0
#define LURCH_MAX 0
#define PLOD_MIN 0
#define PLOD_MAX 0
#define ROTX_MIN 0
#define ROTX_MAX 0
#define ROTY_MIN 0
#define ROTY_MAX 0
#define ROTZ_MIN 0
#define ROTZ_MAX 0

@interface BlurpVC ()
@property SparklineContainerView* sparklinesView;
@property NSArray* plotTypes;

//Data structures to store historical and avergage values of sensor properties
@property(strong, nonatomic) NSMutableArray* cadenceValues;
@property(strong, nonatomic) NSMutableArray* bounceValues;
@property(strong, nonatomic) NSMutableArray* lurchValues;
@property(strong, nonatomic) NSMutableArray* plodValues;
@property(strong, nonatomic) NSMutableArray* rotxValues;
@property(strong, nonatomic) NSMutableArray* rotyValues;
@property(strong, nonatomic) NSMutableArray* rotzValues;

@property(assign, nonatomic) double avgCadence;
@property(assign, nonatomic) double avgBounce;
@property(assign, nonatomic) double avgLurch;
@property(assign, nonatomic) double avgPlod;
@property(assign, nonatomic) double avgRotx;
@property(assign, nonatomic) double avgRoty;
@property(assign, nonatomic) double avgRotz;
@end

//========================
@implementation BlurpVC
//========================

//-----------------------
-(instancetype) init
{
    self = [super init];
    if(self){
        _cadenceValues = [NSMutableArray new];
        _bounceValues = [NSMutableArray new];
        _lurchValues = [NSMutableArray new];
        _plodValues = [NSMutableArray new];
        _rotxValues = [NSMutableArray new];
        _rotyValues = [NSMutableArray new];
        _rotzValues = [NSMutableArray new];
    }
    return self;
}

//-----------------------
- (void)viewDidLoad
//-----------------------
{
    [super viewDidLoad];
}

//-----------------------
- (void)didReceiveMemoryWarning
//-----------------------
{
    [super didReceiveMemoryWarning];
}

//---------------------------------
- (void) btnBack:(id)sender
//---------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
//    SensoPlex *senso = g_app.connectVc.sensoPlex;
//    [senso sendString:@"qhoff"];
//    [senso sendString:@"qsoff"];
}


//-----------------------
- (void) loadView
//-----------------------
{
    NSMutableArray* plotTypes = [NSMutableArray new];
    // Colors are 'Dashing Color Palette' from www.color-hex.com
    plotTypes[0] = [SparklinePlotType newWithMetricName:@"Cadence"
                                               maxValue:@(300)
                                                  color:RGB(0xf04245)];
    plotTypes[1] = [SparklinePlotType newWithMetricName:@"Bounce"
                                               maxValue:@(15)
                                                  color:RGB(0xf3bb33)];
    plotTypes[2] = [SparklinePlotType newWithMetricName:@"Lurch"
                                               maxValue:@(1.2)
                                                  color:RGB(0x63bd4e)];
    plotTypes[3] = [SparklinePlotType newWithMetricName:@"Plod"
                                               maxValue:@(600)
                                                  color:RGB(0x1d99d4)];
    plotTypes[4] = [SparklinePlotType newWithMetricName:@"Rotx"
                                               maxValue:@(40)
                                                  color:RGB(0x673089)];
    plotTypes[5] = [SparklinePlotType newWithMetricName:@"Roty"
                                               maxValue:@(40)
                                                  color:RGB(0xf04245)];
    plotTypes[6] = [SparklinePlotType newWithMetricName:@"Rotz"
                                               maxValue:@(40)
                                                  color:RGB(0xf3bb33)];
    
    SparklineContainerView* scv =
    [[SparklineContainerView alloc] initWithPlotTypes:plotTypes];
    scv.translatesAutoresizingMaskIntoConstraints = NO;
    scv.backgroundColor = [UIColor whiteColor];
    [scv doLayout:self];
    self.sparklinesView = scv;
    self.view = [UIView new];
    [self.view addSubview:scv];
    
    // Add a navigation bar at the top
    //--------------------------------
//    UINavigationBar *navbar =
//    [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 26, 320, 44)];
    UINavigationBar* navbar = [UINavigationBar new];
    navbar.translatesAutoresizingMaskIntoConstraints = NO;
    navbar.delegate = self;
    // Add title to bar
    UINavigationItem *navitem = [UINavigationItem new];
    navitem.title = @"Running";
    // Add back button
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(btnBack:)];
    navitem.leftBarButtonItem = btnBack;
    
    navbar.items = @[navitem];
    [self.view addSubview:navbar];
    [self.view addConstraints:VF_CONSTRAINT(@"H:|[navbar]|", nil
                                            , NSDictionaryOfVariableBindings(navbar))];
    [self.view addConstraints:VF_CONSTRAINT(@"H:|[scv]|", nil
                                            , NSDictionaryOfVariableBindings(scv))];
    [self.view addConstraints:VF_CONSTRAINT(@"V:|-20-[navbar][scv]|", nil
                                            , NSDictionaryOfVariableBindings(navbar, scv))];
} // loadView()

// Pass in values to update the sparklines
//----------------------------------
- (void) cadence:(NSNumber*)cadence
          bounce:(NSNumber*)bounce
           lurch:(NSNumber*)lurch
            plod:(NSNumber*)plod
            rotx:(NSNumber*)rotx
            roty:(NSNumber*)roty
            rotz:(NSNumber*)rotz
//----------------------------------
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* point = @{CADENCE:cadence
                                ,BOUNCE:@([bounce floatValue] / 10)
                                ,LURCH:@([lurch floatValue] / 100)
                                ,PLOD:@([plod floatValue] * 20)
                                ,ROTX:rotx
                                ,ROTY:roty
                                ,ROTZ:rotz
                                };
        [self.sparklinesView plotPoints:point];
        [self.sparklinesView postTips:[self getCoachingTips:point]
                            withColor:[UIColor redColor]];
    });
} // [cadence ...]


-(NSArray*) getCoachingTips:(NSDictionary*) dataPoint
{
    NSMutableArray* tips = [NSMutableArray new];
    while(self.cadenceValues.count>=AVG_SAMPLE_SIZE){
        [self.cadenceValues removeObjectAtIndex:0];
        [self.bounceValues removeObjectAtIndex:0];
        [self.lurchValues removeObjectAtIndex:0];
        [self.plodValues removeObjectAtIndex:0];
        [self.rotxValues removeObjectAtIndex:0];
        [self.rotyValues removeObjectAtIndex:0];
        [self.rotzValues removeObjectAtIndex:0];
    }
    
    [self.cadenceValues addObject:dataPoint[CADENCE]];
    [self.bounceValues addObject:dataPoint[BOUNCE]];
    [self.lurchValues addObject:dataPoint[LURCH]];
    [self.plodValues addObject:dataPoint[PLOD]];
    [self.rotxValues addObject:dataPoint[ROTX]];
    [self.rotyValues addObject:dataPoint[ROTY]];
    [self.rotzValues addObject:dataPoint[ROTZ]];
    
    self.avgCadence = [self calculateAvg:self.cadenceValues];
    self.avgBounce = [self calculateAvg:self.bounceValues];
    self.avgLurch = [self calculateAvg:self.lurchValues];
    self.avgPlod = [self calculateAvg:self.plodValues];
    self.avgRotx = [self calculateAvg:self.rotxValues];
    self.avgRoty = [self calculateAvg:self.rotyValues];
    self.avgRotz = [self calculateAvg:self.rotzValues];
    //if the min and max are the same that means that there is threshold for this parameter
    if(CADENCE_MAX != CADENCE_MIN){
        if(self.avgCadence < CADENCE_MIN){
            [tips addObject:[NSString stringWithFormat:@"Your cadence %d is too low. "
                             @"Increase cadence", (int)self.avgCadence]];
        }
        else if(self.avgCadence > CADENCE_MAX){
            [tips addObject:[NSString stringWithFormat:@"Your cadence %d is too high. "
                             @"Decrease cadence", (int)self.avgCadence]];
        }
    }
    if(BOUNCE_MIN != BOUNCE_MAX){
        if(self.avgBounce < BOUNCE_MIN){
            [tips addObject:[NSString stringWithFormat:@"Your bounce %d is too low."
                             @"Increase bounce", (int)self.avgBounce]];
        }
        else if(self.avgBounce > BOUNCE_MAX){
            [tips addObject:[NSString stringWithFormat:@"Your bounce %d is too high."
                             @"Decrease bounce", (int)self.avgBounce]];
        }
    }
    return tips;
}

-(double) calculateAvg:(NSArray*) dataPoints
{
    if(dataPoints.count==0)
        return 0;
    double total = 0;
    for(NSNumber* value in dataPoints){
        total += value.floatValue;
    }
    return total/dataPoints.count;
}

#pragma mark UiScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y != 0){
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
        
    }
//    CGFloat width = self.sparklinesView.bounds.size.width;
    if(self.sparklinesView.tileViews.count >0){
        CGPoint rightEdge = ((SparklineView*)((SparklineTileView*)self.sparklinesView
                                              .tileViews[0])
                             .sparklineViews[0]).lastPoint;
        rightEdge = [scrollView convertPoint:rightEdge
                                    fromView:((SparklineView*)
                                              ((SparklineTileView*)self
                                               .sparklinesView.tileViews[0])
                                              .sparklineViews[0])];
        if(scrollView.contentOffset.x > rightEdge.x){
            [scrollView setContentOffset:CGPointMake(rightEdge.x, 0)];
        }
    }
}
@end // BlurpVC
