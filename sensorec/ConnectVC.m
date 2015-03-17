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
    NSString *str = nsprintf(@"%s\n",bytes+1);
    [g_app.consoleVc pr:str color:BLUE];
} // onUserMsgReceived

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
