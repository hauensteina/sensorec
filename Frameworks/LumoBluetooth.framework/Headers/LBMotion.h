//
//  LBMotion.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBMotion : NSObject
/**
 *  Acceleration, measured in units of g (9.8 m/s^2)
 */
@property (assign, nonatomic, readonly) float accelerometer_x;
@property (assign, nonatomic, readonly) float accelerometer_y;
@property (assign, nonatomic, readonly) float accelerometer_z;

/**
 *  Magnetometer, measured in gauss
 */
@property (assign, nonatomic, readonly) float magnetometer_x;
@property (assign, nonatomic, readonly) float magnetometer_y;
@property (assign, nonatomic, readonly) float magnetometer_z;

/**
 *  Gyroscope, measured in degrees per second
 */
@property (assign, nonatomic, readonly) float gyro_x;
@property (assign, nonatomic, readonly) float gyro_y;
@property (assign, nonatomic, readonly) float gyro_z;

/**
 *  Temperature, measured in Celsius
 */
@property (assign, nonatomic, readonly) float temperature;

/**
 *  Pressure, measured in Pascals
 */
@property (assign, nonatomic, readonly) float pressure;

@end
