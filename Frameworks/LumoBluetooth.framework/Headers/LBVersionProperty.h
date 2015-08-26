//
//  LBVersionProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/16/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBVersion.h"

@interface LBVersionProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBVersion* version;

@end
