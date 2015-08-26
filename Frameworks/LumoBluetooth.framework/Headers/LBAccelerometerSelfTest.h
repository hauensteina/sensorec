//
//  LBAccelerometerSelfTest.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBAccelerometerSelfTest : NSObject
@property (assign, nonatomic, readonly) int16_t sx;
@property (assign, nonatomic, readonly) int16_t sy;
@property (assign, nonatomic, readonly) int16_t sz;
@property (assign, nonatomic, readonly) int16_t ax;
@property (assign, nonatomic, readonly) int16_t ay;
@property (assign, nonatomic, readonly) int16_t az;

@end
