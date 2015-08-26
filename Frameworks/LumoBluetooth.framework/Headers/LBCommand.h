//
//  LBCommand.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/12/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
#import "LBPacket.h"

typedef NS_ENUM(uint16_t, LBCommandType) {
    LBCommandTypeNone = 0,            // Should not be used
    LBCommandTypeGetProperty = 1,
    LBCommandTypeSetProperty = 2,
    LBCommandTypeMint = 3,
    LBCommandTypeUpload = 4,
    LBCommandTypeMotorOn = 5,
    LBCommandTypeIndicatorOnV0 = 6,   // Possibly Deprecated
    LBCommandTypeUpdateErase = 7,
    LBCommandTypeUpdateCommit = 8,
    LBCommandTypeBluetoothTest = 9,
    LBCommandTypeEnterMode = 10,
    LBCommandTypeNotifyProperty = 11,
    LBCommandTypeRestart = 12,
    LBCommandTypeDisconnect = 13,
    LBCommandTypeIndicatorOn = 14,
    
    LBCommandTypeLumoJSON = 0x8000,    // Start all Lumo commands here onwards
    LBCommandTypeLumoSDB = LBCommandTypeLumoJSON+1
};

@class LBCommand;
@class LBPeripheral;
typedef void(^LBCommandResponseBlock)(LBPeripheral* __nonnull peripheral, LBCommand* __nonnull request, LBCommand* __nonnull response);

@interface LBCommand : NSObject
@property (assign, nonatomic, readonly) LBCommandType commandType;
@property (copy, nonatomic, nullable) LBCommandResponseBlock responseBlock;

/**
 *  Subscribe to this command by listening to notifications posted with the value in this name. It will be different for every subclass.
 *
 *  @return notification name that you can subscribe to via the NSNotificationCenter
 */
+ (nonnull NSString*)notificationName;

/**
 *  Packet containing the information needed to transmit
 *
 *  @return pack with this command and values encoded
 */
- (nonnull LBPacket*)packet;

@end
