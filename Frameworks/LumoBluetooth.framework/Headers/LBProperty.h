//
//  LBProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/13/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  Throws LBInvalidArgumentException if property does not have a valid command type of get, set, notify.


#import "LBCommand.h"

typedef NS_ENUM(uint8_t, LBPropertyType) {
    LBPropertyTypeNone = 0,          // Should not be used
    LBPropertyTypeVersion = 1,
    LBPropertyTypeRTC = 2,
    LBPropertyTypeQuiet = 3,
    LBPropertyTypeSensingTime = 4,
    LBPropertyTypeHardwareId = 5,
    LBPropertyTypeCommunication = 6,
    LBPropertyTypeBatteryState = 7,
    LBPropertyTypeStorageStates = 8,
    LBPropertyTypeUpdateMetaData = 9,
    LBPropertyTypeUpdateCRCs = 10,
    LBPropertyTypeTouchSettings = 11,
    LBPropertyTypeBluetoothTestReport = 12,
    LBPropertyTypeAccelerometerSettings = 13,
    LBPropertyTypePluginInactive = 14,
    LBPropertyTypeTouchInactive = 15,
    LBPropertyTypeSoftId = 16,
    LBPropertyTypeStackUsage = 17,
    LBPropertyTypeAccelerometerSelfTest = 18,
    LBPropertyTypeRTCSelfTest = 19,
    LBPropertyTypeModeSettings = 20,
    LBPropertyTypeDebugLock = 21,
    LBPropertyTypeUpdateMetaDataV2 = 22,
    LBPropertyTypeBatteryStateV2 = 23,
    LBPropertyTypeLogging = 24,
    LBPropertyTypeReset = 25,
    LBPropertyTypeMotion = 26,
    LBPropertyTypePlatform = 27,
    
    LBPropertyTypeEcho = 30  // Make sure echo is last
};

@interface LBProperty : LBCommand
@property (assign, nonatomic, readonly) LBPropertyType propertyType;   // Throws InvalidArgumentException if not
/*!
 *  Converts an LBCommand into an NSArray of LB Commands
 *
 *  @param LBCommand LBCommand to append
 *
 *  @return NSArray containing an array of LB Commands
 */

@end
 