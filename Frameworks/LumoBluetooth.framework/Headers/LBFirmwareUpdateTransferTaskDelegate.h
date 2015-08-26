//
//  LBFirmwareUpdateTransferTaskDelegate.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 8/2/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;
#import "LBPeripheral.h"
#import "LBFirmwareUpdateCommitTask.h"

@protocol LBFirmwareUpdateTransferTaskDelegate <NSObject>
@required

/**
 *  Called as the firmware transfers over to the peripheral to monitor how much of the firmware data has transferred so far.
 *
 *  @param peripheral peripheral receiving the firmware update
 *  @param progress   a value between 0 and 1; 1 represents 100% transfer of the data
 */
- (void)peripheral:(nonnull LBPeripheral*)peripheral firmwareUpdateTransferProgress:(double)progress;

/**
 *  Once the firmware has been transferred over to the peripheral, which may take several minutes, this method is called with the commit task.
 *  It is the responsibility of the delegate to execute `commitTask start` whenever it is appropriate, as this will apply the firmware and restart 
 *  the sensor.
 *
 *  @param peripheral peripheral whose firmware is ready with new firmware
 *  @param commitTask task to execute if the firmware transferred correctly; nil if firmware did not transfer properly
 *  @param error      error message describing what went wrong during firmware transfer; nil if no error.
 */
- (void)peripheral:(nonnull LBPeripheral*)peripheral firmwareUpdateTransferCompleted:(nullable LBFirmwareUpdateCommitTask*)commitTask error:(nullable NSError*)error;

@end
