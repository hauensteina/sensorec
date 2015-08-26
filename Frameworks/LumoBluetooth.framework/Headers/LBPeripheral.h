//
//  LBPeripheral.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/19/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  Do not change CBPeripheral delegate.

@import Foundation;
@import CoreBluetooth;
#import "LBProperty.h"
#import "LBRadarPong.h"
#import "LBVersion.h"
#import "LBBatteryState.h"
#import "LBFirmwareMetadata.h"
#import "LBPlatform.h"

@class LBPeripheral;
@protocol LBFirmwareUpdateTransferTaskDelegate;
typedef void(^LBRSSIBlock)(LBPeripheral* __nonnull lbPeripheral, NSNumber* __nonnull RSSI);

//////////////////////////////////////////////////////////////////////////////////////////////

@protocol LBPeripheralDelegate <CBPeripheralDelegate>
@required

- (void)peripheral:(nonnull LBPeripheral*)peripheral didUpdateState:(CBPeripheralState)state;
- (void)peripheral:(nonnull LBPeripheral *)peripheral didReceiveCommand:(nonnull LBCommand*)command;
@end

//////////////////////////////////////////////////////////////////////////////////////////////

@interface LBPeripheral : NSObject
@property (weak, nonatomic, nullable) id<LBPeripheralDelegate> delegate;
@property (assign, nonatomic, readonly) CBPeripheralState state;
@property (copy, nonatomic, nonnull, readonly) NSNumber* RSSI;      // Last read RSSI

// Information
@property (copy, nonatomic, nullable, readonly) NSString* hardwareId;   // Cannot be reset
@property (copy, nonatomic, nullable, readonly) NSString* softId;       // Can be reset via command
@property (strong, nonatomic, nullable, readonly) LBVersion* version;
@property (strong, nonatomic, nullable, readonly) LBPlatform* platform;
@property (strong, nonatomic, nullable, readonly) LBBatteryState* batteryState;
@property (strong, nonatomic, nullable, readonly) LBFirmwareMetadata* baseFirmwareMetadata;
@property (strong, nonatomic, nullable, readonly) LBFirmwareMetadata* pluginFirmwareMetadata;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithPeripheral:(nonnull CBPeripheral*)peripheral;
+ (nullable instancetype)createPeripheral:(nonnull CBPeripheral*)peripheral;

- (CBPeripheralState)state;
- (nonnull NSUUID*)identifier;

/**
 *  Reads the RSSI value asynchronously and will call the rssiBlock with the peripheral and RSSI value once it is received. Only received once.
 *
 *  @param rssiBlock RSSI block to receive RSSI data
 */
- (void)readRSSIWithBlock:(nonnull LBRSSIBlock)rssiBlock;

/**
 *  Send a command to the peripheral
 *
 *  @param command command to send to the peripheral
 */
- (void)sendCommand:(nonnull LBCommand*)command;

/**
 *  Send an array of commands; slightly more efficient than calling sendCommand: N timess
 *
 *  @param commands list of commands to send to the peripheral
 */
- (void)sendCommands:(nonnull NSArray<LBCommand*>*)commands;

/**
 *  Updates the peripheral's firmware to the desired firmware encapsulated in baseFirmwareData and/or pluginFirmwareData.
 *  Either baseFirmwareData or pluginFirmwareData should be nonnull. Setting both to nil will return an error through delegate callback.
 *
 *  @param baseFirmwareData data containing the new base firmware; nil if no new base firmware
 *  @param pluginFirmwareData   data containing the new plugin firmware; nil if no new plugin firmware
 *  @param delegate         delegate to receive information during the upgrade process
 */
- (void)updateBaseFirmware:(nullable NSData*)baseFirmwareData pluginFirmware:(nullable NSData*)pluginFirmwareData delegate:(nonnull id<LBFirmwareUpdateTransferTaskDelegate>)delegate;

/**
 *  Activates the Radar Service. Will receive LBRadarPong objects via NSNotifications. Can only activate if we are in `state == CBPeripheralStateConnected`.
 */ 
- (void)activateRadarService;

@end
