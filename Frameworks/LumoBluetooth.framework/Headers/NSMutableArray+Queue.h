//
//  NSMutableArray+Queue.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 8/2/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  FIFO

@import Foundation;

@interface NSMutableArray<ObjectType> (Queue)

/**
 *  Adds an item to the queue. It will be added according to FIFO rules.
 *
 *  @param object object to be added
 */
- (void)enqueue:(nonnull ObjectType)object;

/**
 *  Remove an object from the queue, according to FIFO rules
 *
 *  @return object object that was removed from queue; nil if queue is empty
 */
- (nullable ObjectType)dequeue;

/**
 *  Take a look at the next object that will be dequeued, without actually dequeuing it
 *
 *  @return object next to be dequeued, but keeping it in queue. nil if queue is empty. Equivalent to `[array firstObject]`.
 */
- (nullable ObjectType)peek;

@end
