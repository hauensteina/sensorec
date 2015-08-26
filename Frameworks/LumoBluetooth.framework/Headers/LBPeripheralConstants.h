//
//  LBPeripheralContants.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/19/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

/**
 *  @const  LBServiceLumoBackUUID
 *
 *  @discussion Lumo Back Sensor Advertising Service UUID
 */
CB_EXTERN NSString* const LBServiceLumoBackUUID;

/**
 *  @const  LBServiceLumoLiftUUID
 *  
 *  @discussion Lumo Lift Sensor Advertising Service UUID
 */
CB_EXTERN NSString* const LBServiceLumoLiftUUID;

/**
 *  @const  LBServiceLumoFlightUUID
 *
 *  @discussion Lumo Flight Sensor Advertising Service UUID
 */
CB_EXTERN NSString* const LBServiceLumoFlightUUID;

/**
 *  Used to ping for certain Lumo Devices
 */
CB_EXTERN NSString* const LBServiceRadarUUID;

/**
 *  @discussion Minimum RSSI value, i.e. -128. According to Bluetooth SIG, RSSI is a signed int8, [-128,+127]
 */
CB_EXTERN int8_t const LBPeripheralRSSIMinimum;

/**
 *  @discussion Maximum RSSI value, i.e. 127. According to Bluetooth SIG, RSSI is a signed int8, [-128,+127]
 */
CB_EXTERN int8_t const LBPeripheralRSSIMaximum;

/**
 *  Key used in user info when commands are sent via NSNotifications
 */
CB_EXTERN NSString* const LBPeripheralKey;

NS_ASSUME_NONNULL_END