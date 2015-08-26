//
//  LBStackUsageProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"

@interface LBStackUsageProperty : LBProperty
@property (assign, nonatomic, readonly) uint32_t stackContentUsed;
@property (assign, nonatomic, readonly) uint32_t stackDepthUsed;

@end
