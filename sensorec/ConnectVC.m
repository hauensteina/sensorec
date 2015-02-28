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

//=========================
@interface ConnectVC ()
//=========================
// List of discovered Sensoplex devices
@property NSMutableArray *discoveredSensos;
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


//=======================================
# pragma mark SensoPlexDelegate methods
//=======================================

//------------------------------------------------------------------
- (void) didDiscoverSensoplexPeripheral:(CBPeripheral *)peripheral
//------------------------------------------------------------------
{
    [_discoveredSensos addObject:peripheral];
    //[_devicesTableView reloadData];
}



@end
