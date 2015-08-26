//
//  LBStorageStateProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/16/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBStorageState.h"

@interface LBStorageStateProperty : LBProperty
/*!
 @abstract
 
 @discussion LBQuietProperty sets the quiet property for the sensor. Quieting the sensor will stop it from buzzing.
 */
@property (strong, nonatomic, nonnull, readonly) NSArray<LBStorageState*>* states;

@end

