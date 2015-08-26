//
//  LBStorageState.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

@import Foundation;

@interface LBStorageState : NSObject
@property (assign, nonatomic, readonly) uint8_t type;
@property (assign, nonatomic, readonly) BOOL isDataSeries;
@property (assign, nonatomic, readonly) BOOL flushOnIdle;
@property (assign, nonatomic, readonly) BOOL upload;
@property (assign, nonatomic, readonly) uint8_t priority;
@property (assign, nonatomic, readonly) uint16_t startPage;
@property (assign, nonatomic, readonly) uint16_t pageCount;
@property (assign, nonatomic, readonly) uint16_t firstUsedPage;
@property (assign, nonatomic, readonly) uint16_t usedPageCount;
@property (assign, nonatomic, readonly) uint8_t recordSize;
@property (assign, nonatomic, readonly) NSTimeInterval interval;

@end
