//
//  LBPlatformProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBPlatform.h"

@interface LBPlatformProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) LBPlatform* platform;

@end
