//
//  LBActivity.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

typedef NS_OPTIONS(uint8_t, LBInactive) {
    LBInactiveByUser = 1 << 0,
    LBInactiveByMode = 1 << 1,
    LBInactiveByLowBattery = 1 << 2
};

@interface LBActivity : NSObject
@property (assign, nonatomic) LBInactive reason;
@property (assign, nonatomic) BOOL active;
@end
