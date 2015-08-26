//
//  LBIndicatorCommand.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 8/2/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBCommand.h"

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import AppKit;
#endif

typedef NS_ENUM(uint8_t, LBIndicatorStyle) {
    LBIndicatorStyleSteady = 1,
    LBIndicatorStyleBreathe = 2
};

@interface LBIndicatorCommand : LBCommand
@property (assign, nonatomic, readonly) NSTimeInterval duration;
@property (assign, nonatomic, readonly) LBIndicatorStyle style;
@property (assign, nonatomic, readonly) uint8_t current;
@property (assign, nonatomic, readonly) uint32_t pause;

#if TARGET_OS_IPHONE
@property (strong, nonatomic, nonnull, readonly) UIColor* color;

- (nonnull instancetype)initWithColor:(nonnull UIColor*)color duration:(NSTimeInterval)duration style:(LBIndicatorStyle)style current:(uint8_t)current;

- (nonnull instancetype)initWithColor:(nonnull UIColor*)color duration:(NSTimeInterval)duration style:(LBIndicatorStyle)style pause:(uint32_t)pause;
#else
@property (strong, nonatomic, nonnull, readonly) NSColor* color;

- (nonnull instancetype)initWithColor:(nonnull NSColor*)color duration:(NSTimeInterval)duration style:(LBIndicatorStyle)style current:(uint8_t)current;

- (nonnull instancetype)initWithColor:(nonnull NSColor*)color duration:(NSTimeInterval)duration style:(LBIndicatorStyle)style pause:(uint32_t)pause;
#endif

@end
