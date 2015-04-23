//
//  AppDelegate.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVC.h"
#import "ConnectVC.h"
#import "ConsoleVC.h"

//================================================================
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//================================================================

@property MainVC *mainVc;
@property ConnectVC *connectVc;
@property ConsoleVC *consoleVc;
@property UINavigationController *naviVc;

@property NSString *sensoApp; // sensorun or sensolifting firmware
@property NSTimer *secTimer; // Check various things once per second
@property BOOL gotSensoApp;

// Options
@property NSMutableDictionary *options;

@property (strong, nonatomic) UIWindow *window;

- (void) saveOptions;

@end

