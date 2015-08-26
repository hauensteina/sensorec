//
//  LBFirmwareUpdateMetadata.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(uint8_t, LBFirmwareType) {
    LBFirmwareTypeBase,
    LBFirmwareTypePlugin
};

typedef NS_OPTIONS(uint32_t, LBFirmwareMetadataFlag) {
    LBFirmwareMetadataFlagNone = 0,
    LBFirmwareMetadataFlagEncrypted = 1 << 0
};

//TODO: Should not be an enumeration; instead 3 is the minimum version that dictates encryption
typedef NS_ENUM(uint32_t, LBFirmwareMetadataVersion) {
    LBFirmwareMetadataVersionNone = 0,
    LBFirmwareMetadataVersionNotEncrypted = 2,
    LBFirmwareMetadataVersionEncrypted = 3,
    LBFirmwareMetadataVersionUnknown = 0xffffffff
};

@interface LBFirmwareMetadata : NSObject
@property (assign, nonatomic, readonly) LBFirmwareType type;
@property (assign, nonatomic, readonly) uint32_t version;           // Can use LBFirmwareUpdateMetadataVersion as comparison metrics to guarentee functionality
@property (assign, nonatomic, readonly) uint32_t revision;
@property (assign, nonatomic, readonly) uint32_t length;
@property (strong, nonatomic, nonnull, readonly) NSDate* date;
@property (strong, nonatomic, nullable, readonly) NSData* digest;
@property (assign, nonatomic, readonly) LBFirmwareMetadataFlag flags;
@property (strong, nonatomic, nullable, readonly) NSData* encryptedInitialization;
@property (strong, nonatomic, nullable, readonly) NSData* encryptedDigest;

@end
