//
//  LBModeSettings.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBModeSettings : NSObject
@property (assign, nonatomic) NSTimeInterval holdDuration;
@property (assign, nonatomic) uint8_t vibrateCycles;
@property (assign, nonatomic) uint8_t vibrateLevel;
@property (assign, nonatomic) NSTimeInterval vibrateOnDuration;
@property (assign, nonatomic) NSTimeInterval vibrateOffDuration;

@end
