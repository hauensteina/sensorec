//
//  LBFirmwareUpdateCommitTask.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 8/12/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
#import "LBTask.h"

@interface LBFirmwareUpdateCommitTask : LBTask
@property (strong, nonatomic, nullable, readonly) LBFirmwareMetadata* baseFirmwareMetadata;
@property (strong, nonatomic, nullable, readonly) LBFirmwareMetadata* pluginFirmwareMetadata;

- (nonnull instancetype)initWithPeripheral:(nonnull LBPeripheral*)peripheral baseFirmwareMetadata:(nullable LBFirmwareMetadata*)baseMetadata pluginFirmwareMetadata:(nullable LBFirmwareMetadata*)pluginMetadata;

@end
