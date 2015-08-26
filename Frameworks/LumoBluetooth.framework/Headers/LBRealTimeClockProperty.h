//
//  LBRealTimeClockProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/12/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
/*!
  @abstract Gets and sets value for LBRealTimeClockProperty
 
  @discussion LBRealTimeClockProperty sets the time on the LBProperty
 */
@interface LBRealTimeClockProperty : LBProperty
/*!
 *  Checks the date on the sensor with an NSDate
 *
 *  @param NSDate NSDate to initialize
 *
 *  @return NSDate NSDate with the commandType set to LBCommandTypeSetProperty and a date
 */
@property (strong, nonatomic, nullable, readonly) NSDate* date;
/**
 *  Description
 *  @discussion
 */
@property (assign, nonatomic, readonly, getter=isSet) BOOL set;
/*!
 *  Initializes an NSDate with a command time and date
 *
 *  @param NSDate NSDate to initialize
 *
 *  @return NSDate NSDate with the commandType set to LBCommandTypeSetProperty and a date
 */
- (nonnull instancetype)initWithTime:(nonnull NSDate*)date;

@end
