//
//  LBBatteryStateProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/16/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBBatteryState.h"

@interface LBBatteryStateProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBBatteryState* batteryState;

/*!
 *  Initializes a LBBatteryStateProperty
 *
 *  @return LBBatteryStateProperty with a LBCommandTypeGetProperty and LBPropertyTypeBatteryStateV2
 */
- (nonnull instancetype)initV2;

@end
