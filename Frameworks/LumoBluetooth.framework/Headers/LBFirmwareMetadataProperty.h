//
//  LBFirmwareUpdateMetadataProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBFirmwareMetadata.h"

@interface LBFirmwareMetadataProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBFirmwareMetadata* baseFirmwareMetadata;
@property (strong, nonatomic, nullable, readonly) LBFirmwareMetadata* pluginFirmwareMetadata;

- (nonnull instancetype)initV2;

@end
