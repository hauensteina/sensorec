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
@property (weak, nonatomic) IBOutlet UILabel *lbRecording;
@property (weak, nonatomic) IBOutlet UILabel *lbRecords;
@property (weak, nonatomic) IBOutlet UILabel *lbBytes;
@property (weak, nonatomic) IBOutlet UILabel *lbTotal;
@property (weak, nonatomic) IBOutlet UIButton *btnLed;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;

@property BOOL ledOn;
@property BOOL recording;

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
    
    // Get data logging space,used,records,...
    // The callback is onSensorLogStatusParsed().
    [connectVC.sensoPlex getLogStatus];
} // viewDidAppear()

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
    if (!_ledOn) {
        [g_app.connectVc.sensoPlex setLED:LEDGreen];
        _ledOn = YES;
        [_btnLed setTitle:@"LED off" forState:UIControlStateNormal];
    }
    else {
        [g_app.connectVc.sensoPlex setLED:LEDSystemControl];
        _ledOn = NO;
        [_btnLed setTitle:@"LED green" forState:UIControlStateNormal];
    }
}

//--------------------------------
- (IBAction)btnRecord:(id)sender
//--------------------------------
{
    ConnectVC *connectVC = g_app.connectVc;
    if (_recording) {
        [connectVC.sensoPlex stopLoggingData];
    } else {
        [connectVC.sensoPlex startLoggingData];
    }
    [connectVC.sensoPlex getLogStatus];
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
    _lbRecording.text = status;
    _lbRecords.text = nRecords;
    _lbBytes.text = usedBytes;
    _lbTotal.text = totalBytes;
    
    if ([status isEqualToString:@"YES"]) {
        [_btnRecord setTitle:@"Stop Recording" forState:UIControlStateNormal];
        _recording = YES;
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


//
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

