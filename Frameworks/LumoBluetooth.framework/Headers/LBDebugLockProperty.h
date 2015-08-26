//
//  LBDebugLockProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  Activates debugging only; there is no way to query existing debug state.
//  Sends a response packet of current debug lock state

#import "LBProperty.h"

@interface LBDebugLockProperty : LBProperty
@property (assign, nonatomic, readonly) BOOL locked;
@end
