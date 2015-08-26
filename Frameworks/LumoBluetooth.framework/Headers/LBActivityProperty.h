//
//  LBActivityProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"
#import "LBActivity.h"

@interface LBActivityProperty : LBProperty
@property (strong, nonatomic, nullable, readonly) NSArray<LBActivity*>* activities;

- (nonnull instancetype)initWithActivity:(nonnull LBActivity*)activity;

@end
