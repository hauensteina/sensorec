//
//  LBSoftIdProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"

@interface LBSoftIdProperty : LBProperty
@property (copy, nonatomic, nullable, readonly) NSString* softId;

- (nonnull instancetype)initWithSoftId:(nonnull NSString*)softId;

@end
