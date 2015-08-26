//
//  LBTask.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 8/15/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
#import "LBPeripheral.h"

@interface LBTask : NSObject
@property (weak, nonatomic, readonly) LBPeripheral* peripheral;

- (nonnull instancetype)initWithPeripheral:(nonnull LBPeripheral*)peripheral;

/**
 *  Starts the task.
 */
- (void)start;

/**
 *  Abstract method that gets called when `start` is called. This is the entry point for a task, so start your task logic in this method.
 *  Subclasses should override this method to start their task logic.
 *
 *  Default implemetnation does nothing.
 */
- (void)main;

@end
