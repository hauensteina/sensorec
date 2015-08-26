//
//  LBPlatform.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(uint8_t, LBPlatformProduct) {
    LBPlatformProductBack,
    LBPlatformProductLift,
    LBPlatformProductFlight   // Used in Lift V2 and Flight
};

typedef NS_ENUM(uint8_t, LBPlatformProcessor) {
    LBPlatformProcessorEFM32,
    LBPlatformProcessorNRF51
};

// To be deprecated
typedef NS_ENUM(uint8_t, LBPlatformBoard) {
    LBPlatformBoardMax,
    LBPlatformBoardMod,
    LBPlatformBoardMin,
    LBPlatformBoardMix
} NS_DEPRECATED_IOS(0.1, 1.0);

@interface LBPlatform : NSObject
@property (assign, nonatomic, readonly) LBPlatformProduct product;
@property (assign, nonatomic, readonly) LBPlatformProcessor processor;
@property (assign, nonatomic, readonly) LBPlatformBoard board NS_DEPRECATED_IOS(0.1, 1.0);
@property (assign, nonatomic, readonly) uint8_t major;
@property (assign, nonatomic, readonly) uint8_t minor;
@end
