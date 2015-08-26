//
//  LBCommunicationProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/13/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"

typedef NS_OPTIONS(uint8_t, LBCommunicationFlag) {
    LBCommunicationFlagNone = 0,
    LBCommunicationFlagUpload = 1 << 0,     //  Enables communication over BLE from plugin.
    LBCommunicationFlagPlugin = 1 << 1,     //  Enables communication over BLE from plugin.
    LBCommunicationFlagActive = 1 << 2      //  This tells the device that the app is active (when YES) or running in the background (when NO).
};

@interface LBCommunicationProperty : LBProperty
/*!
 @abstract LBCommunicationProperty sets the flag of the current communication state of the sensor.
 
 @discussion LBCommunciationProperty can have a flag that is either set to none, upload, plugin, or active. These states are used to determine what state the sensor is in 
*/
@property (assign, nonatomic) LBCommunicationFlag flags;
/*!
 *  Initializes a LBCommunicationProperty with the passed LBCommunicationFlag
 *
 *  @param LBCommunicationFlag  to initialize the LBCommunicationProperty
 *
 *  @return LBCommunicationProperty containing the LBCommunicationFlag passed in
 */
- (nonnull instancetype)initWithFlags:(LBCommunicationFlag)flags;

@end
