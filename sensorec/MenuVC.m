//
//  MenuVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-19.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "MenuVC.h"
#import "common.h"
#import "Utils.h"

@interface MenuVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnSounds;
@property (weak, nonatomic) IBOutlet UIButton *btnCalibSound;
@end

@implementation MenuVC


//------------------
- (void)viewDidLoad
//------------------
{
    [super viewDidLoad];
    NSDictionary *opts = g_app.options;
    [_btnSounds setTitle:opts[@"sounds"] forState:UIControlStateNormal];
    [_btnCalibSound setTitle:opts[@"calib_sound_flag"] forState:UIControlStateNormal];
}


//-------------------------------
- (IBAction)btnBack:(id)sender
//-------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
}

//--------------------------------
- (IBAction)btnSounds:(id)sender
//--------------------------------
{
    NSString *opt = g_app.options[@"sounds"];
    if ([opt isEqualToString:@"System"]) {
        opt = @"Andreas";
    }
    else {
        opt = @"System";
    }
    [_btnSounds setTitle:opt forState:UIControlStateNormal];
    g_app.options[@"sounds"] = opt;
    [g_app saveOptions];
}

//------------------------------------
- (IBAction)btnCalibSound:(id)sender
//------------------------------------
{
    NSString *opt = g_app.options[@"calib_sound_flag"];
    if ([opt isEqualToString:@"ON"]) {
        opt = @"OFF";
    }
    else {
        opt = @"ON";
    }
    [_btnCalibSound setTitle:opt forState:UIControlStateNormal];
    g_app.options[@"calib_sound_flag"] = opt;
    [g_app saveOptions];
}


@end
