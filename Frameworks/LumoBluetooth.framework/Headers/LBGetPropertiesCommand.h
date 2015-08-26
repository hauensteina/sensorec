//
//  LBGetPropertiesCommand.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/12/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBCommand.h"

@interface LBGetPropertiesCommand : LBCommand

/**
 *  An array or LBPropertyTypes to retreive from the peripheral
 */
@property (copy, nonatomic, nonnull) NSArray<NSNumber*>* properties;

@end
