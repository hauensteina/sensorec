//
//  LBTouchSettings.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBTouchSettings : NSObject
@property (assign, nonatomic, readwrite) uint8_t lowPower;
@property (assign, nonatomic, readwrite) uint8_t atiTarget;
@property (assign, nonatomic, readwrite) uint8_t buttonAtiBase;
@property (assign, nonatomic, readwrite) uint8_t buttonThreshold;
@property (assign, nonatomic, readwrite) uint8_t wearAtiBase;
@property (assign, nonatomic, readwrite) uint8_t wearThreshold;

@end
