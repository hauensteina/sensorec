//
//  AppDelegate.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MainVC.h"
#import "ConnectVC.h"
#import "ConsoleVC.h"
#import "BrickVC.h"
#import "BlurpVC.h"

//================================================================
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//================================================================

@property (strong, nonatomic) UIWindow *window;
@property MainVC *mainVc;
@property ConnectVC *connectVc;
@property ConsoleVC *consoleVc;
@property BrickVC *brickVc;
@property BlurpVC *blurpVc;
@property UINavigationController *naviVc;

//@property NSString *sensoApp; // sensorun or sensolifting firmware
@property NSTimer *secTimer; // Check various things once per second

// Things we have learned about the plugin (aka xrm)
@property NSString *xrmPlatform;

// Options
@property NSMutableDictionary *options;

// Sounds
@property SystemSoundID backStraightSound;


- (void) saveOptions;

@end

