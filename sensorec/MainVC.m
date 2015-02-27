//
//  MainVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "MainVC.h"
#import "common.h"
#import "Utils.h"
#import "prm.h"
#import <CoreMotion/CMMotionManager.h>
#import <AudioToolbox/AudioToolbox.h>
#import <math.h>
#import <stdint.h>

// Vertical displacement with time and length in ticks
//================================
@interface Displacement:NSObject
//================================
@property float displ;
@property int t;
@property int len;
@end

@implementation Displacement
@end

//=====================
@interface MainVC ()
//=====================

// UI Elements
//---------------
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// Sounds
//----------------------
@property SystemSoundID badSound;
@property SystemSoundID goodSound;
@property SystemSoundID moreUpSound;
@property SystemSoundID moreDownSound;
@property SystemSoundID backStraightSound;

@end

//======================
@implementation MainVC
//======================

#pragma  mark View LifeCycle

//---------------------
- (void)viewDidLoad
//---------------------
{
    NSURL *soundURL;
    soundURL = [[NSBundle mainBundle] URLForResource:@"badsound"
                                              withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_badSound);

    soundURL = [[NSBundle mainBundle] URLForResource:@"goodsound"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_goodSound);

    soundURL = [[NSBundle mainBundle] URLForResource:@"more_up"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_moreUpSound);

    soundURL = [[NSBundle mainBundle] URLForResource:@"more_down"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_moreDownSound);
    
    soundURL = [[NSBundle mainBundle] URLForResource:@"backstraight"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_backStraightSound);
    
    
    
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];

} // viewDidLoad()


//--------------------------
- (void) playBadSound
//--------------------------
{
    if ([g_app.options[@"sounds"] isEqualToString:@"System"]) {
        [self playSystemSound:@"low_power"];
    }
    else {
        AudioServicesPlaySystemSound (_badSound);
        //AudioServicesPlayAlertSound(_badSound); // also vibrates
    }
}
//--------------------------
- (void) playGoodSound
//--------------------------
{
    if ([g_app.options[@"sounds"] isEqualToString:@"System"]) {
        [self playSystemSound:@"SIMToolkitPositiveACK"];
    }
    else {
        AudioServicesPlaySystemSound (_goodSound);
        //AudioServicesPlayAlertSound(_badSound); // also vibrates
    }
}
//--------------------------
- (void) playStraightSound
//--------------------------
{
    AudioServicesPlaySystemSound (_backStraightSound);
}

#pragma mark Button Callbacks

//------------------------------------
- (IBAction)btnConnect:(id)sender
//------------------------------------
{
    [g_app.naviVc pushViewController:g_app.connectVc animated:YES];
}

#pragma mark UI Helpers

//-------------------------------
- (void) popup:(NSString *)msg
         title:(NSString *)title
//-------------------------------
{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:title
                               message:msg
                              delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alert show];
}

//---------------------------------------------
- (void) playSystemSound:(NSString *)soundName
//---------------------------------------------
// Play an iOS system sound.
// List can be found at
// https://github.com/TUNER88/iOSSystemSoundsLibrary
{
    NSString *fullPath =
    nsprintf (@"/System/Library/Audio/UISounds/%@.caf",soundName);
    NSURL *fileURL = [NSURL URLWithString:fullPath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark Userdefaults

#define DEF [NSUserDefaults standardUserDefaults]

//-----------------------------------------------------
- (void) putNum:(NSString *)key val:(NSNumber *)val
//-----------------------------------------------------
// Store a number in UserDefaults
{
    [DEF setObject:val forKey:key];
}

//-----------------------------------------------------
- (NSNumber *) getNum:(NSString *)key
//-----------------------------------------------------
// Get number from UserDefaults
{
    return [DEF objectForKey:key];
}

//-----------------------------------------------------
- (int) getInt:(NSString *)key
//-----------------------------------------------------
// Get number from UserDefaults, return as int
{
    return [[DEF objectForKey:key] intValue];
}

//-----------------------------------------------------
- (NSString *) getStr:(NSString *)key
//-----------------------------------------------------
// Get object from UserDefaults, return as string
{
    id obj = [DEF objectForKey:key];
    return obj ? nsprintf (@"%@", [DEF objectForKey:key]) : @"" ;
}

#pragma mark Json 

//-----------------------------------------
- (NSString*) generateJSON:(id)theObject
//-----------------------------------------
// Convert any NSObject to a JSON representation
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theObject
                                                       options:0 error:&error];
    if (!jsonData) {
        NSLog (@"failed to convert object to json: %@",theObject);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return nsprintf (@"%@\n",jsonString);
} // generateJSON

//-----------------------------------------
- (id) parseJSON:(NSString*)theJSON
//-----------------------------------------
// Parse Json into an NSObject
{
    NSData *theData = [theJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *theError = nil;
    id objFromJson = [NSJSONSerialization JSONObjectWithData:theData
                                                     options:0
                                                       error:&theError];
    if (!objFromJson)
    {
        NSLog (@"failed parse json: %@",theJSON);
        return nil;
    }
    return objFromJson;
} // parseJSON

@end // MainVC

