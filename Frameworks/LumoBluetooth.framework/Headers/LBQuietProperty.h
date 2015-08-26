//
//  LBQuietProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/12/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"

@interface LBQuietProperty : LBProperty
/*!
 @abstract Gets and sets the quiet mode for the sensor
 
 @discussion LBQuietProperty sets the quiet property for the sensor. Quieting the sensor will stop it from buzzing.
 */
@property (assign, nonatomic, readonly) BOOL quiet;
/*!
 *  Initalizes a LBQuietProperty with a given BOOL value for quiet
 *
 *  @param BOOL BOOL quiet
 *
 *  @return LBQuietProperty  
 */
- (nonnull instancetype)initWithQuiet:(BOOL)quiet;

@end
