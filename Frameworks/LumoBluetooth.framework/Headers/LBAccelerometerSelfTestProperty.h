//
//  LBAccelerometerSelfTestProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBAccelerometerSelfTest.h"

@interface LBAccelerometerSelfTestProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBAccelerometerSelfTest* test;

@end
