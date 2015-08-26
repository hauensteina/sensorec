//
//  LBModeSettingsProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBModeSettings.h"

@interface LBModeSettingsProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBModeSettings* settings;

- (nonnull instancetype)initWithSettings:(nonnull LBModeSettings*)settings;
@end
