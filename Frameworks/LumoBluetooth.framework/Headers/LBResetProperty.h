//
//  LBResetProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  This is purely a response packet from the peripheral. Do not attempt to send it.

#import "LBProperty.h"

typedef NS_ENUM(uint32_t, LBResetCause) {
    LBResetCauseNone = 0,
    LBResetCausePowerOn = 1 << 0,
    LBResetCauseBrownOutUnregulated = 1 << 2,
    LBResetCauseBrownOutRegulated = 1 << 3,
    LBResetCausePinReset = 1 << 4,
    LBResetCauseLockup = 1 << 5,
    LBResetCauseSystemRequest = 1 << 6,
};

@interface LBResetProperty : LBProperty
@property (assign, nonatomic, readonly) LBResetCause cause;
@property (assign, nonatomic, readonly) uint32_t time;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
