//
//  LBLoggingProperty.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/18/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBProperty.h"

typedef NS_OPTIONS(uint32_t, LBLoggingType) {
    LBLoggingTypeDiagnostics = 1 << 0,
    LBLoggingTypeAssertions = 1 << 1
};

@interface LBLoggingProperty : LBProperty
@property (assign, nonatomic, readonly) LBLoggingType flags;

- (nonnull instancetype)initWithLoggingFlags:(LBLoggingType)flags;

@end
