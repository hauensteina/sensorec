//
//  ConnectVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-27.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "ConnectVC.h"
#import "MainVC.h"
#import "common.h"
#import "Utils.h"
#import "../SensoPlexLibrary/SensoPlex.h"
#import "../SensoPlexLibrary/SensorDataLogStatus.h"
#import "BluetoothMasterCell.h"

//=========================
@interface ConnectVC ()
//=========================
// List of discovered Sensoplex devices
@property NSMutableArray *discoveredSensos;
@property (weak, nonatomic) IBOutlet UITableView *tbvSensos;

@end

//=========================
@implementation ConnectVC
//=========================

//-------------------
- (void)viewDidLoad
//-------------------
{
    [super viewDidLoad];
   
    [self initializeSensoPlex];
    _discoveredSensos = [NSMutableArray new];
}

//-------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------
{
    [self disconnectConnectedSenso];
    [self scanForSensos];
}

//==========================
#pragma mark - SensoPlex
//==========================

//-----------------------------
- (void) initializeSensoPlex
//-----------------------------
{
    if( !self.sensoPlex ) {
        SensoPlex *sensoPlex = [SensoPlex new];
        self.sensoPlex = sensoPlex;
    }
    self.sensoPlex.delegate = self;
}

//----------------------
- (void) scanForSensos
//----------------------
{
    [_discoveredSensos removeAllObjects];
    [_tbvSensos reloadData];
    
    if(self.sensoPlex.state == SensoPlexScanning)
        [self.sensoPlex stopScanningForBLEPeripherals];
    
    // If we are not connected, then scan for our peripheral to connect to
    SensoPlexState state = self.sensoPlex.state;
    if ( state == SensoPlexDisconnected || state == SensoPlexFailedToConnect ) {
        [self.sensoPlex discoverBLEPeripherals];
    } else {
        //[self showConnectionState:state];
    }
} // scanForSensos()

//------------------------
- (void) connectToSenso
//------------------------
// Connecting means scanning for all of them (after discovery)
// and then remembering the BLE characteristics only for
// the sensor matching _mySenso. The check whether to connect
// happens in the shouldConnectToSensoPlexPeripheral() callback.
{
    NSLog (@">>>>>> Senso State: %d", self.sensoPlex.state);
    switch (self.sensoPlex.state) {
        case SensoPlexConnected:
            [self disconnectConnectedSenso];
            break;
        case SensoPlexReady:
            [self disconnectConnectedSenso];
            break;
        case SensoPlexDisconnected:
            [self.sensoPlex scanForBLEPeripherals]; // connects to _mySenso
            break;
        case SensoPlexScanning:
            [self.sensoPlex stopScanningForBLEPeripherals];
            [self.sensoPlex scanForBLEPeripherals]; // connects to _mySenso
            break;
        default:
            break;
    }
}

//----------------------------------
- (void) disconnectConnectedSenso
//----------------------------------
{
    if(self.sensoPlex.isCapturingData)
        [self.sensoPlex stopCapturingData];
    [self.sensoPlex stopScanningForBLEPeripherals];
    [self.sensoPlex cleanup];
    self.mySenso = nil;
    self.connected = NO;
    //[self showConnectionState:self.sensoPlex.state];
}


//=======================================
# pragma mark SensoPlexDelegate methods
//=======================================

//------------------------------------------------------------------
- (void) didDiscoverSensoplexPeripheral:(CBPeripheral *)peripheral
                                   name:(NSString *)name
//------------------------------------------------------------------
{
    // Populate the tableview. If we come across our last known
    // sensor, connect immediately.
    [_discoveredSensos addObject:@[peripheral,name]];
    [_tbvSensos reloadData];
    
    NSString *currentSenso = getStr (@"currentSenso");
    if ([name isEqualToString:currentSenso]) {
        _mySenso = peripheral;
        _mySensoName = currentSenso;
        [self connectToSenso];
    }
}

//---------------------------------------------------------------------
- (BOOL) shouldConnectToSensoPlexPeripheral:(CBPeripheral*)peripheral
//---------------------------------------------------------------------
// Control which SensoPlex peripheral to connect to.
// This returns YES if the peripheral is _mySenso.
// Clicking in the tableView sets _mySenso.
{
    if([peripheral.identifier isEqual:_mySenso.identifier])
    {
        _connected = YES;
        return YES;
    }
    return NO;
}

// connection state callback
//---------------------------------------
- (void) onSensoPlexConnectStateChange
//---------------------------------------
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SensoPlexState state = self.sensoPlex.state;
        [self handleConnectionState:state];
    });
}

//-----------------------------------------------------
- (void) handleConnectionState:(SensoPlexState) state
//-----------------------------------------------------
// Not a delegate method. Called on main thread from
// onSensoPlexConnectStateChange()
{
    switch (state) {
        case SensoPlexConnecting: {
            break;
        }
        case SensoPlexConnected: {
            g_app.gotSensoApp = NO;
            break;
        }
        case SensoPlexReady: {
            [self.sensoPlex setRTC];
            if ([g_app.naviVc topViewController] == g_app.connectVc) {
                [g_app.naviVc popViewControllerAnimated:YES];
            }
            break;
        }
        case SensoPlexDisconnected: {
            if ([g_app.naviVc.viewControllers count] == 1) {
                [g_app.naviVc pushViewController:g_app.connectVc animated:YES];
            }
            [self scanForSensos];
            break;
        }
        case SensoPlexFailedToConnect: {
            break;
        }
        case SensoPlexScanning: {
            break;
        }
        case SensoPlexBluetoothError: {
        }
        default: {
            [self popup: nsprintf (@"unknown sensor state %d",state)
                  title:@"Error"];
        }
            break;
    }
}  // handleConnectionState()

//------------------------------------------------------------
- (void) onSensorLogStatusParsed:(SensorDataLogStatus *)data
//------------------------------------------------------------
// Callback when we retrieve log data status
{
    // Firmware unknown
    if (!g_app.gotSensoApp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Wait..." forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = NO;
            g_app.mainVc.lbRecords.hidden = YES;
            g_app.mainVc.lbBytes.hidden = YES;
            g_app.mainVc.lbTotal.hidden = YES;
            g_app.mainVc.btnLed.hidden = YES;
            g_app.mainVc.lbRecordsUsed.hidden = YES;
            g_app.mainVc.lbBytesUsed.hidden = YES;
            g_app.mainVc.lbTotlab.hidden = YES;
            g_app.mainVc.btnClear.hidden = YES;
        });
    }
    
    // Lifting demo
    if ([g_app.sensoApp isEqualToString:@"sensolifting"]) return;

    // Any other firmware
    MainVC *mainVC = g_app.mainVc;
    NSString *status = nsprintf(@"%@",data.enabled ? @"YES" : @"NO");
    NSString *usedBytes = nsprintf (@"%.0f", data.logUsedBytes);
    NSString *totalBytes = nsprintf (@"%.0f", data.logTotalBytes);
    NSString *nRecords = nsprintf (@"%.0f", data.logNumberOfRecords);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainVC setLogStatus:status used:usedBytes total:totalBytes records:nRecords];
    });
}

//-------------------------------------------------------
- (void) onUserMsgReceived:(Byte *)bytes
                       len:(int)length
//-------------------------------------------------------
// Application (aka PRM) message from sensor.
// Called from SensoPlex.m
{
    static int msgNum = 0;
    static NSArray *currentBlurp;
    msgNum++;
    //    SensoPlex *senso = g_app.connectVc.sensoPlex;
    if (bytes[1] == '@') { // binary key/value message
        NSMutableArray *keys = [NSMutableArray new];
        NSMutableArray *values = [NSMutableArray new];
        int16_t val16;
        int32_t val32;
        long val;
        for (unsigned char *p=bytes+2; *p; p++) {
            if (*p == '@') { continue; }
            unsigned char c = *p;
            if (c >= 'a' && c <= 'z') { // lower case, 16 bit
                ((char *)&val16)[0] = *++p;
                ((char *)&val16)[1] = *++p;
                [keys addObject:nsprintf(@"%c",c)];
                val = val16; // for 64-bit phones
                [values addObject:nsprintf(@"%ld",val)];
            }
            else { // upper case, 32 bit
                ((char *)&val32)[0] = *++p;
                ((char *)&val32)[1] = *++p;
                ((char *)&val32)[2] = *++p;
                ((char *)&val32)[3] = *++p;
                [keys addObject:nsprintf(@"%c",c)];
                val = val32; // for 64-bit phones
                [values addObject:nsprintf(@"%ld",val)];
            }
        } // for
        // Hardware Sensor Fusion  Quaternion
        if ([keys isEqualToArray:@[@"w",@"x",@"y",@"z"]]) {
            [g_app.brickVc fusionFU];
            [g_app.brickVc animateQuaternion:values];
        }
        // Software Open Source Quaternion
        else if ([keys isEqualToArray:@[@"v",@"x",@"y",@"z"]]) {
            [g_app.brickVc fusionOS];
            [g_app.brickVc animateQuaternion:values];
        }
        // Cadence, Bounce, Lurch, Plod
        else if ([keys isEqualToArray:@[@"c",@"b",@"l",@"p"]]) {
            [g_app.consoleVc pr:keys values:values num:msgNum];
            // Remember blurp values until rotations come in
            currentBlurp = values;
        }
        // Rotation around x,y,z
        else if ([keys isEqualToArray:@[@"r",@"y",@"z"]]) {
            [g_app.consoleVc pr:keys values:values num:msgNum];
            [g_app.blurpVc cadence:currentBlurp[0]
                            bounce:currentBlurp[1]
                             lurch:currentBlurp[2]
                              plod:currentBlurp[3]
                              rotx:values[0]
                              roty:values[1]
                              rotz:values[2]];
        }
        else {
            [g_app.consoleVc pr:keys values:values num:msgNum];
        }
    }
    else { // string msg
        //msgNum++;
        NSString *str = nsprintf(@"%s",bytes+1);
        [g_app.consoleVc pr:str num:msgNum];
        [self handleStrMsg:str];
    }
    //[g_app.consoleVc pr:nsprintf (@"%ld ",msgNum) color:RGB(0x0f7002)];
} // onUserMsgReceived

//-----------------------------------------
- (void) handleStrMsg: (NSString *)msg
//-----------------------------------------
// A string message from the sensor came in. Deal with it.
{
    if ([msg isEqualToString:@"lifting"]) {
        g_app.sensoApp = @"sensolifting";
        g_app.gotSensoApp = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Lifting" forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = NO;
            g_app.mainVc.lbRecords.hidden = YES;
            g_app.mainVc.lbBytes.hidden = YES;
            g_app.mainVc.lbTotal.hidden = YES;
            g_app.mainVc.btnLed.hidden = NO;
            g_app.mainVc.lbRecordsUsed.hidden = YES;
            g_app.mainVc.lbBytesUsed.hidden = YES;
            g_app.mainVc.lbTotlab.hidden = YES;
            g_app.mainVc.btnClear.hidden = YES;
            g_app.mainVc.btnShutter.hidden = NO;
            g_app.mainVc.btnAnimation.hidden = YES;
            g_app.mainVc.btnBlurp.hidden = YES;
        });
    }
    else if ([msg isEqualToString:@"run"]) {
        g_app.sensoApp = @"sensorun";
        g_app.gotSensoApp = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
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
            g_app.mainVc.btnAnimation.hidden = YES;
            g_app.mainVc.btnBlurp.hidden = YES;
        });
    }
    else if ([msg isEqualToString:@"dev"]) {
        g_app.sensoApp = @"sensodev";
        g_app.gotSensoApp = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
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
            g_app.mainVc.btnBlurp.hidden = NO;
        });
    }
    else if ([msg hasPrefix:@"gl:"]) {
        int minangle = [[msg componentsSeparatedByString:@":"][1] intValue];
        //if (minangle > 50) {
        if (minangle > 45) {
            [self playGoodSound];
        } else {
            [self playStraightSound];
        }
    }
    else if ([msg hasPrefix:@"bl:"]) {
        [self playBadSound];
    }
    else if ([msg hasPrefix:@"calib"]) {
        NSString *opt = g_app.options[@"calib_sound_flag"];
        if ([opt isEqualToString:@"ON"]) {
            [self playCalibSound];
        }
    }
} // handleStrMsg

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
//--------------------------
- (void) playCalibSound
//--------------------------
{
    [self playSystemSound:@"photoShutter"];
}
//--------------------------
- (void) playStraightSound
//--------------------------
{
    AudioServicesPlaySystemSound (g_app.backStraightSound);
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

//=========================================
# pragma mark TableView delegate methods
//=========================================

//-----------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-----------------------------------------------------------------
{
    return 1;
}

//-----------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
//-----------------------------------------------------------------
{
    return _discoveredSensos.count;
}

//----------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
//----------------------------------------------------
{
    return 50;
}

//-----------------------------------------------------
- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------
{
    CBPeripheral *peripheral = _discoveredSensos[indexPath.row][0];
    NSString *name = _discoveredSensos[indexPath.row][1];
    
    NSString *cellId = @"cellID";
    BluetoothMasterCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[BluetoothMasterCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellId];
    }
    
    [cell.label1 setText:@"-"];
    //[cell.label2 setText:peripheral.name];
    [cell.label2 setText:name];
    [cell.label3 setText:@"-"];
    [cell.label4 setText:peripheral.RSSI.stringValue];
    if(cell.label4.text.length)
        [cell.label4 setText:@"-"];
    
    return cell;
} // cellForRowAtIndexPath

//-----------------------------------------------------
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------
{
    _mySenso = _discoveredSensos[indexPath.row][0];
    _mySensoName = _discoveredSensos[indexPath.row][1];
    [self connectToSenso];
} // didSelectRowAtIndexPath

//----------------------------------------------
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
//----------------------------------------------
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

//----------------------------------------------
- (UIView*)tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section
//----------------------------------------------
{
    return [[UIView alloc] init];
}

//------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
//------------------------------------------------
{
    return 0;
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


@end
