//
//  LBBatteryState.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/16/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBBatteryState : NSObject
@property (assign, nonatomic, readonly) double batteryVoltage;
@property (assign, nonatomic, readonly) BOOL hasUSBPower;
@property (assign, nonatomic, readonly) BOOL isCharging;
@property (assign, nonatomic, readonly) double chargeCurrent;
@property (assign, nonatomic, readonly) double systemCurrent;
@property (assign, nonatomic, readonly) double batteryCharge;
@property (assign, nonatomic, readonly) double temperature;

- (double)batteryChargePercent;

@end
