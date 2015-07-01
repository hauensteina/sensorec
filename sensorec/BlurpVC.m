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
    plotTypes[0] = [SparklinePlotType newWithMetricName:@"Cadence"
                                               maxValue:@(300)
                                                  color:[UIColor greenColor]];
    plotTypes[1] = [SparklinePlotType newWithMetricName:@"Bounce"
                                               maxValue:@(150)
                                                  color:[UIColor redColor]];
    plotTypes[2] = [SparklinePlotType newWithMetricName:@"Lurch"
                                               maxValue:@(120)
                                                  color:[UIColor blueColor]];
    plotTypes[3] = [SparklinePlotType newWithMetricName:@"Plod"
                                               maxValue:@(15)
                                                  color:[UIColor yellowColor]];
    plotTypes[4] = [SparklinePlotType newWithMetricName:@"Rotx"
                                               maxValue:@(45)
                                                  color:[UIColor greenColor]];
    plotTypes[5] = [SparklinePlotType newWithMetricName:@"Roty"
                                               maxValue:@(45)
                                                  color:[UIColor redColor]];
    plotTypes[6] = [SparklinePlotType newWithMetricName:@"Rotz"
                                               maxValue:@(45)
                                                  color:[UIColor blueColor]];
    
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
        NSDictionary* point = @{@"Cadence":cadence
                                ,@"Bounce":bounce
                                ,@"Lurch":lurch
                                ,@"Plod":plod
                                ,@"Rotx":rotx
                                ,@"Roty":roty
                                ,@"Rotz":rotz
                                };
        [self.sparklinesView plotPoints:point];
    });
} // [cadence ...]

@end // BlurpVC
