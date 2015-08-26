//
//  LBMotion.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBMotion : NSObject
@property (assign, nonatomic, readonly) int16_t accelerometer_x;
@property (assign, nonatomic, readonly) int16_t accelerometer_y;
@property (assign, nonatomic, readonly) int16_t accelerometer_z;

@property (assign, nonatomic, readonly) int16_t magnetometer_x;
@property (assign, nonatomic, readonly) int16_t magnetometer_y;
@property (assign, nonatomic, readonly) int16_t magnetometer_z;

@property (assign, nonatomic, readonly) int16_t gyro_x;
@property (assign, nonatomic, readonly) int16_t gyro_y;
@property (assign, nonatomic, readonly) int16_t gyro_z;

@property (assign, nonatomic, readonly) int16_t temperature;

@property (assign, nonatomic, readonly) uint32_t pressure;

@end
