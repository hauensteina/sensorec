//
//  AppDelegate.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"
#import "ConnectVC.h"
#import "ConsoleVC.h"
#import "Utils.h"

@import AVFoundation;

AppDelegate *g_app;

@interface AppDelegate ()

@end

@implementation AppDelegate


//-------------------------------------------------------------
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-------------------------------------------------------------
{
    g_app = self;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.mainVc = [MainVC new];
    self.connectVc = [ConnectVC new];
    self.consoleVc = [ConsoleVC new];
    self.brickVc = [BrickVC new];
    self.blurpVc = [BlurpVC new];
    
    // The Navigation Controller
    self.naviVc  = [UINavigationController alloc];
    self.naviVc = [self.naviVc initWithRootViewController:self.mainVc];
    [self.naviVc pushViewController:self.connectVc animated:NO];
    //self.naviVc = [self.naviVc initWithRootViewController:self.connectVc];
    self.naviVc.navigationBar.hidden = YES;
    
    self.window.rootViewController = [self naviVc];
    [self.window makeKeyAndVisible];
    
    // Read Options
    self.options = [NSMutableDictionary new];
    NSArray *opts = [Utils readObjectsFromJsonFile:@"options.txt"];
    if ([opts count]) {
        self.options = [opts[0] mutableCopy];
    }
    
    // Set option defaults if not there
    if (!_options[@"calib_sound_flag"]) { _options[@"calib_sound_flag"] = @"ON"; }
    [self saveOptions];
    
    self.sensoApp = @"sensorun";
    
    NSURL *soundURL;
    soundURL = [[NSBundle mainBundle] URLForResource:@"backstraight"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL
                                      ,&_backStraightSound);
    
    _gotSensoApp = NO;
    _secTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(secTimer:)
                                               userInfo:nil
                                                repeats:YES];
    [self configureAVAudioSession];
    
    
    return YES;
} // didFinishLaunchingWithOptions



- (void) configureAVAudioSession
{
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                             error:&error];
    
    if (!success)  NSLog(@"AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:&error];
    if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"AVAudioSession error activating: %@",error);
    else NSLog(@"audioSession active");
    
}

//-----------------------------
- (void) secTimer:(id)sender
//-----------------------------
// Called once a sec to do periodic things
{
    static int count = 0;
    count++;
    if (!_gotSensoApp&& [g_app.connectVc.peripheral state] == CBPeripheralStateConnected) {
        LBJSONCommand* jsonCommand = [[LBJSONCommand alloc] initWithCommandString:@"PLATFORM"];
        [g_app.connectVc.peripheral sendCommand:jsonCommand];
        
//        SensoPlex *senso = g_app.connectVc.sensoPlex;
//        [senso sendString:@"app"];
    }
} // secTimer

//-------------------
- (void) saveOptions
//-------------------
{
    [Utils makeEmptyFile:@"options.txt"];
    [Utils appendObjToFileAsJSON:_options fname:@"options.txt"];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
