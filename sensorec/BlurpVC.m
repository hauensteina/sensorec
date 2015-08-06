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
#import "Coach.h"

@interface BlurpVC ()
@property SparklineContainerView* sparklinesView;
@property NSArray* plotTypes;

@end

//========================
@implementation BlurpVC
//========================


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
        Coach* coach = [Coach sharedInstance];
        [self.sparklinesView postTips:[coach getCoachingTips:point]];
    });
} // [cadence ...]



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
