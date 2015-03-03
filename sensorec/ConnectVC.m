//
//  ConnectVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-27.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "ConnectVC.h"
#import "common.h"
#import "../SensoPlexLibrary/SensoPlex.h"
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
    [self scanForSensos];
}

//------------------------------
- (IBAction)btnBack:(id)sender
//------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
}

//-------------------------------
- (IBAction)btnScan:(id)sender
//-------------------------------
{
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
    //[_devicesTableView reloadData];
    
    if(self.sensoPlex.state == SensoPlexScanning)
        [self.sensoPlex stopScanningForBLEPeripherals];
    
    // Sensoplex
    // if we are not connected, then scan for our peripheral to connect to
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
    [_discoveredSensos addObject:@[peripheral,name]];
    [_tbvSensos reloadData];
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



@end
