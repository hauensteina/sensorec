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
#import "MenuVC.h"

//================================================================
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//================================================================

@property MainVC *mainVc;
@property MenuVC *menuVc;
@property ConnectVC *connectVc;
@property ConsoleVC *consoleVc;
@property UINavigationController *naviVc;

// Options
@property NSMutableDictionary *options;

@property (strong, nonatomic) UIWindow *window;

- (void) saveOptions;

@end

