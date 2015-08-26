//
//  LBMotionProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBMotion.h"

@interface LBMotionProperty : LBProperty
@property (strong, nonatomic, nonnull, readonly) LBMotion* motion;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
