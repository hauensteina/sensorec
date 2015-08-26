//
//  LBSensingTimeProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/16/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
/*!
 @abstract LBTimeSensingProperty reads date and time from a passed LBProperty
 
 @discussion LBTimeSensingProperty reads date and time from a passed LBProperty
 */
@interface LBSensingTimeProperty : LBProperty
/*!
 *  NSDate date sets a date value
 */
@property (strong, nonatomic, nullable, readonly) NSDate* date;
/*!
 *  Initializes an LBSensingTimeProperty with a passed NSDate
 *
 *  @param NSDate NSDate to initalize the date
 *
 *  @return LBSensingProperty with LBCommandSetProperty and NSDate
 */
- (nonnull instancetype)initWithTime:(nonnull NSDate*)date;
@end
