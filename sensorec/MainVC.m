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
//#import "prm.h"
#import <CoreMotion/CMMotionManager.h>
#import <AudioToolbox/AudioToolbox.h>
#import <math.h>
#import <stdint.h>
#import "SettingsViewController.h"

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
@property (weak, nonatomic) IBOutlet UILabel *lbSensor;
//@property (weak, nonatomic) IBOutlet UILabel *lbRecording;

@property BOOL ledOn;
@property BOOL recording;
@property NSTimer *tmStatus;

@end

//======================
@implementation MainVC
//======================

#pragma  mark View LifeCycle

//---------------------
- (void)viewDidLoad
//---------------------
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];

} // viewDidLoad()

//-------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------
{
    [self adaptGUI2XrmPlatform: g_app.xrmPlatform];
    ConnectVC *connectVC = g_app.connectVc;
    if (!connectVC.connected) {
        [g_app.naviVc pushViewController:connectVC animated:YES];
        return;
    }
    NSString *name = connectVC.mySensoName;
    if (name) {
        _lbSensor.text = name;
        putStr (name, @"currentSenso");
    }
    else {
        _lbSensor.text = @"<no_name>";
    }

    // Set title for shutter sound button
    NSString *opt = g_app.options[@"calib_sound_flag"];
    if ([opt isEqualToString:@"ON"]) {
        [_btnShutter setTitle:@"Turn Off Shutter Sound"
                     forState:UIControlStateNormal];
    } else {
        [_btnShutter setTitle:@"Turn On Shutter Sound"
                     forState:UIControlStateNormal];
    }

} // viewDidAppear()

// Change GUI depending on xrm PLATFORM
//----------------------------------------------------
- (void) adaptGUI2XrmPlatform: (NSString *)platf
{
    //    if ([platf isEqualToString:@"lifting"]) {
    //        dispatch_async (dispatch_get_main_queue(), ^{
    //            [g_app.mainVc.btnRecord setTitle:@"Lifting" forState:UIControlStateNormal];
    //            g_app.mainVc.btnRecord.enabled = NO;
    //            g_app.mainVc.lbRecords.hidden = YES;
    //            g_app.mainVc.lbBytes.hidden = YES;
    //            g_app.mainVc.lbTotal.hidden = YES;
    //            g_app.mainVc.btnLed.hidden = NO;
    //            g_app.mainVc.lbRecordsUsed.hidden = YES;
    //            g_app.mainVc.lbBytesUsed.hidden = YES;
    //            g_app.mainVc.lbTotlab.hidden = YES;
    //            g_app.mainVc.btnClear.hidden = YES;
    //            g_app.mainVc.btnShutter.hidden = NO;
    //            g_app.mainVc.btnAnimation.hidden = YES;
    //            g_app.mainVc.btnBlurp.hidden = YES;
    //        });
    //    }
    if (!platf) { return; }
    if ([platf hasPrefix: @"flight-s1"]) {
        dispatch_async (dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Start Recording" forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = YES;
            g_app.mainVc.lbRecords.hidden = NO;
            g_app.mainVc.lbBytes.hidden = NO;
            g_app.mainVc.lbTotal.hidden = NO;
            g_app.mainVc.btnLed.hidden = NO;
            g_app.mainVc.lbRecordsUsed.hidden = NO;
            g_app.mainVc.lbBytesUsed.hidden = NO;
            g_app.mainVc.lbTotlab.hidden = NO;
            g_app.mainVc.btnClear.hidden = NO;
            g_app.mainVc.btnShutter.hidden = YES;
            g_app.mainVc.btnAnimation.hidden = NO;
            g_app.mainVc.btnBlurp.hidden = YES;
        });
    }
    else { // unknown platform
        NSLog (@"unknown platform %@", platf);
        dispatch_async (dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Start Recording" forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = NO;
            g_app.mainVc.lbRecords.hidden = YES;
            g_app.mainVc.lbBytes.hidden = YES;
            g_app.mainVc.lbTotal.hidden = YES;
            g_app.mainVc.btnLed.hidden = YES;
            g_app.mainVc.lbRecordsUsed.hidden = YES;
            g_app.mainVc.lbBytesUsed.hidden = YES;
            g_app.mainVc.lbTotlab.hidden = YES;
            g_app.mainVc.btnClear.hidden = YES;
            g_app.mainVc.btnShutter.hidden = YES;
            g_app.mainVc.btnAnimation.hidden = YES;
            g_app.mainVc.btnBlurp.hidden = YES;
        });
    }
    //    else if ([platf hasPrefix:@"gl:"]) {
    //        int minangle = [[msg componentsSeparatedByString:@":"][1] intValue];
    //        //if (minangle > 50) {
    //        if (minangle > 45) {
    //            [self playGoodSound];
    //        } else {
    //            [self playStraightSound];
    //        }
    //    }
    //    else if ([msg hasPrefix:@"bl:"]) {
    //        [self playBadSound];
    //    }
    //    else if ([msg hasPrefix:@"calib"]) {
    //        NSString *opt = g_app.options[@"calib_sound_flag"];
    //        if ([opt isEqualToString:@"ON"]) {
    //            [self playCalibSound];
    //        }
    //    }
} // adaptGUI2XrmPlatform

//--------------------------
- (void) playBadSound
//--------------------------
{
    [self playSystemSound:@"low_power"];
}

//--------------------------
- (void) playGoodSound
//--------------------------
{
    [self playSystemSound:@"SIMToolkitPositiveACK"];
}

//==============================
#pragma mark Button Callbacks
//==============================

//---------------------------------
- (IBAction)btnConsole:(id)sender
//---------------------------------
{
    [g_app.naviVc pushViewController:g_app.consoleVc animated:YES];
}

//------------------------------------
- (IBAction)btnScan:(id)sender
//------------------------------------
{
    putStr (@"",@"currentSenso");
    [g_app.naviVc pushViewController:g_app.connectVc animated:YES];
}

//------------------------------
- (IBAction)btnLed:(id)sender
//------------------------------
{
    NSLog(@"Deprecated Method: %@", NSStringFromSelector(_cmd));
}

//------------------------------------
- (IBAction)btnShutter:(id)sender
//------------------------------------
{
    NSString *opt = g_app.options[@"calib_sound_flag"];
    if ([opt isEqualToString:@"ON"]) {
        opt = @"OFF";
    }
    else {
        opt = @"ON";
    }
    if ([opt isEqualToString:@"ON"]) {
        [_btnShutter setTitle:@"Turn Off Shutter Sound"
                     forState:UIControlStateNormal];
    } else {
        [_btnShutter setTitle:@"Turn On Shutter Sound"
                     forState:UIControlStateNormal];
    }
    g_app.options[@"calib_sound_flag"] = opt;
    [g_app saveOptions];
} // btnShutter

//---------------------------------
- (IBAction)btnClear:(id)sender
//---------------------------------
{
    NSLog(@"Deprecated Method: %@", NSStringFromSelector(_cmd));
}

//--------------------------------
- (IBAction)btnRecord:(id)sender
//--------------------------------
{
    NSLog(@"Deprecated Method: %@", NSStringFromSelector(_cmd));
}

//--------------------------------------
- (IBAction)btnAnimation:(id)sender
//--------------------------------------
{
    [g_app.naviVc pushViewController:g_app.brickVc animated:YES];
}

//---------------------------------
- (IBAction)btnBlurp:(id)sender
//---------------------------------
{
    [g_app.naviVc pushViewController:g_app.blurpVc animated:YES];
}

//-----------------------------------------
- (IBAction)coachButtonClicked:(id)sender
//-----------------------------------------
{
    UIStoryboard* sb = [UIStoryboard
                        storyboardWithName:@"SettingsStoryboard"
                        bundle:nil];
    SettingsViewController* svc = (SettingsViewController*)[sb instantiateInitialViewController];
    [self presentViewController:svc animated:YES completion:^{
        
    }];
}


//-----------------------------
- (void) tmStatus:(id)sender
//-----------------------------
{
    NSLog(@"Deprecated Method: %@", NSStringFromSelector(_cmd));
}

//======================================
#pragma mark Senso info from ConnectVC
//======================================

//---------------------------------------------
- (void) setLogStatus:(NSString *)status
                 used:(NSString *)usedBytes
                total:(NSString *)totalBytes
              records:(NSString *)nRecords
//---------------------------------------------
{
    //_lbRecording.text = status;
    _lbRecords.text = nRecords;
    _lbBytes.text = usedBytes;
    _lbTotal.text = totalBytes;
    
    if ([status isEqualToString:@"YES"]) {
        [_btnRecord setTitle:@"Stop Recording" forState:UIControlStateNormal];
        _recording = YES;
        [_tmStatus invalidate];
        _tmStatus = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(tmStatus:)
                                                   userInfo:nil
                                                    repeats:NO];
        
    }
    else {
        [_btnRecord setTitle:@"Start Recording" forState:UIControlStateNormal];
        _recording = NO;
    }
}


//==============================
#pragma mark UI Helpers
//==============================

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


//==============================
#pragma mark Json
//==============================

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

