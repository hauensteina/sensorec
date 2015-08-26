//
//  LBException.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/25/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@interface LBException : NSException
+ (nonnull NSException*)abstractMethodException:(nonnull SEL)selector inObject:(nonnull id<NSObject>)object;
+ (nonnull NSException*)invalidParameterException:(nonnull NSString*)reason;
+ (nonnull NSException*)rangeException:(NSRange)subRange containerRange:(NSRange)containerRange;
+ (nonnull NSException*)invalidCharacteristicException:(nonnull SEL)selector inObject:(nonnull id<NSObject>)object characteristic:(nonnull CBCharacteristic*)characteristic;
@end
