//
//  LBCentralManager.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/10/15.
//  Copyright (c) 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;
#import "LBPeripheral.h"

@protocol LBCentralManagerDelegate <NSObject>
@required
- (void)centralManagerDidUpdateState:(CBCentralManagerState)state;
- (void)centralManagerDidDiscoverPeripheral:(nonnull LBPeripheral*)peripheral advertisementData:(nonnull NSDictionary<NSString*, id>*)advertisementData RSSI:(nonnull NSNumber*)RSSI;

- (void)centralManagerDidConnectPeripheral:(nonnull LBPeripheral*)peripheral;
- (void)centralManagerDidDisconnectPeripheral:(nonnull LBPeripheral*)peripheral;
- (void)centralManagerDidFailToConnectPeripheral:(nonnull LBPeripheral *)peripheral;

@end

@interface LBCentralManager : NSObject<CBCentralManagerDelegate>
@property (weak, nonatomic) id<LBCentralManagerDelegate> delegate;

/**
 *  Only discover devices that are >= the minimumRSSI value. Default is LBPeripheralRSSIMinimum. Capped to LBPeripheralRSSIMinimum.
 *  Devices already discovered remain discovered until scanning is restarted.
 */
@property (assign, nonatomic) NSInteger minimiumRSSI;

/**
 *  Only discover devices that are <= the maximumRSSI value. Default is LBPeripheralRSSIMaximum. Capped to LBPeripheralRSSIMaximum.
 *  Devices already discovered remain discovered until scanning is restarted.
 */
@property (assign, nonatomic) NSInteger maximumRSSI;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithDelegate:(nonnull id<LBCentralManagerDelegate>)delegate lumoServices:(nonnull NSArray<NSString*>*)lumoProductServices;

- (void)scanForLumoProducts;
- (nonnull NSArray<LBPeripheral*>*)discoveredLumoPeripherals;
- (void)stopScanning;

/**
 *  Remember this peripheral for the lifetime of the app install. If you connect to an LB peripheral, it will always be connected to when in range. The only way to forget the peripheral is to call cancelPeripheral.
 *
 *  @param peripheral Lumo Peripheral that this app should always connect to, now, and in the future
 */
- (void)rememberPeripheral:(nonnull LBPeripheral*)peripheral;

/**
 *  The list of peripherals we have chosen to remember, in alphabetical identifier order
 *
 *  @return array of peripherals we have chosen to remember, in alphabetical identifier order
 */
- (nonnull NSArray<LBPeripheral*>*)rememberedPeripherals;

/**
 *  Forget the peripheral. Can only be re-owned
 *
 *  @param peripheral peripheral to forget
 */
- (void)forgetPeripheral:(nonnull LBPeripheral*)peripheral;

@end
