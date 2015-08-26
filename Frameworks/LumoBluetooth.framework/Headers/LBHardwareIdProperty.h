//
//  LBHardwareIdProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/16/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"

@interface LBHardwareIdProperty : LBProperty
/*!
 @abstract LBHardwareIDProperty sets them hardware ID
 
 @discussion LBQuietProperty sets the hardware ID (NSString*) to the sensor. It is a read only property
 */
@property (copy, nonatomic, nullable, readonly) NSString* hardwareId;
@end

