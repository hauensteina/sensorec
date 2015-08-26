//
//  LBAccelerometerSettingsProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBAccelerometerSettings.h"

@interface LBAccelerometerSettingsProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBAccelerometerSettings* settings;

- (nonnull instancetype)initWithSettings:(nonnull LBAccelerometerSettings*)settings;

@end
