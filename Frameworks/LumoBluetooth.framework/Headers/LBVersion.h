//
//  LBVersion.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
typedef NS_ENUM(uint32_t, LBVersionCapability) {
    LBVersionCapabilityUpdate = 1 << 0,
    LBVersionCapabilityEncrypted = 1 << 1,
    LBVersionCapabilityTemperature = 1 << 2,
    LBVersionCapabilityLogging = 1 << 3,
    LBVersionCapabilityBatteryModel = 1 << 4,
    LBVersionCapabilityIndicate = 1 << 5,
    LBVersionCapabilityReset = 1 << 6,
    LBVersionCapabilityPlatform = 1 << 7,
    
    LBVersionCapabilityDecrypt = 1 << 16     // Not sure why this is so far away
};

@interface LBVersion : NSObject
@property (assign, nonatomic, readonly) uint16_t major;
@property (assign, nonatomic, readonly) uint16_t minor;
@property (assign, nonatomic, readonly) uint32_t revision;
@property (assign, nonatomic, readonly) LBVersionCapability capabilities;

@end
