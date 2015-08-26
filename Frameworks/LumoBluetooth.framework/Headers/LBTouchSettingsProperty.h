//
//  LBTouchSettingsProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBTouchSettings.h"

@interface LBTouchSettingsProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBTouchSettings* settings;
/*!
 *  Sets a LBTouchSettingsProperty with a passed in LBTouchSettings
 *
 *  @param LBTouchSettings describing what settings should be passed in
 *
 *  @return LBTouchSettingsProperty with property type and LBTouchSettings passed in 
 */
- (nonnull instancetype)initWithSettings:(nonnull LBTouchSettings*)settings;

@end
