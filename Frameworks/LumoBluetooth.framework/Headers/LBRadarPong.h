//
//  LBRadarPong.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/27/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBPacket.h"

typedef NS_ENUM(NSInteger, LBRadarPongFlags) {
    LBRadarPongFlagUSBPower = 0x01,
    LBRadarPongFlagCharging = 0x02,
    LBRadarPongFlagButtonPressed = 0x04,
    LBRadarPongFlagWearSensed = 0x08,
    LBRadarPongFlagActive = 0x10,
    LBRadarPongFlagGoodbye = 0x80
};

@interface LBRadarPong : LBPacket
@property (assign, nonatomic, readwrite) double receivedSignalStrength;
@property (assign, nonatomic, readwrite) NSTimeInterval roundTripTime;
@property (assign, nonatomic, readwrite) NSUInteger lostCount;

@property (assign, nonatomic, readonly) uint8_t sequenceNumber;
@property (assign, nonatomic, readonly) uint8_t flags;
@property (assign, nonatomic, readonly) double accelerationX;
@property (assign, nonatomic, readonly) double accelerationY;
@property (assign, nonatomic, readonly) double accelerationZ;
@property (assign, nonatomic, readonly) double batteryVoltage;
@property (assign, nonatomic, readonly) double chargeCurrent;
@property (assign, nonatomic, readonly) double systemCurrent;
@property (assign, nonatomic, readonly) NSTimeInterval pongReceivedTimeIntervalSince1970;
@property (assign, nonatomic, readonly, getter=isUSBPowered) BOOL USBPowered;
@property (assign, nonatomic, readonly, getter=isCharging) BOOL charging;
@property (assign, nonatomic, readonly, getter=isButtonPressd) BOOL buttonPressed;
@property (assign, nonatomic, readonly, getter=isWearSensed) BOOL wearSensed;
@property (assign, nonatomic, readonly, getter=isPluginActive) BOOL pluginActive;

- (nonnull instancetype)initWithData:(nonnull NSData *)data;

+ (nonnull NSString*)notificationName;

@end
