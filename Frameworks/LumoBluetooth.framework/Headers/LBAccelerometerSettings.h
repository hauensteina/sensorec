//
//  LBAccelerometerSettings.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(uint8_t, LBAccelerometerRate) {
    LBAccelerometerRate1,
    LBAccelerometerRate10,
    LBAccelerometerRate25,
    LBAccelerometerRate50,
    LBAccelerometerRate100,
    LBAccelerometerRate200,
    LBAccelerometerRate400
};

typedef NS_ENUM(uint8_t, LBAccelerometerScale) {
    LBAccelerometerScale2,
    LBAccelerometerScale4,
    LBAccelerometerScale8,
    LBAccelerometerScale16
};

@interface LBAccelerometerSettings : NSObject
@property (assign, nonatomic) BOOL lowPower;
@property (assign, nonatomic) LBAccelerometerRate rate;
@property (assign, nonatomic) LBAccelerometerScale scale;

@end
