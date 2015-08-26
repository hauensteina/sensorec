//
//  LBPacket.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/27/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  Immutable
//  @throws NSRangeException if data packet reads

@import Foundation;
@import CoreBluetooth;

@interface LBPacket : NSObject
@property (copy, nonatomic, nonnull, readonly) NSData* data;
@property (assign, nonatomic, readonly) CFByteOrder byteOrder;

/**
 *  Maximum Transfer Unit - defines the largest amount of bytes that can be sent at one time
 *  Default value is 20 bytes.
 */
@property (assign, nonatomic) NSUInteger mtu;

- (nonnull instancetype)init; // No Bytes, Big Endian
- (nonnull instancetype)initWithByteOrder:(CFByteOrder)byteOrder;   // No Bytes
- (nonnull instancetype)initWithData:(nonnull NSData*)data; // Big Endian
- (nonnull instancetype)initWithData:(nonnull NSData*)data inByteOrder:(CFByteOrder)byteOrder NS_DESIGNATED_INITIALIZER;

/**
 *  Creates a new packet whose data is a concentation of the receiver's data and the passed-in parameter data
 *
 *  @param data New Data to append to the Packet
 *
 *  @return new LBPacket whose contents are a concatenation of existing data and new data
 */
- (nonnull instancetype)combineWithData:(nonnull NSData*)data;

/*!
 *  Combines the packet data to the current packet and returns a new packet with the combined data. Does not modify the current contents. This just calls 'appendData:packet.data'.
 *
 *  @param packet packet whose contents you want to append to the receiver's current data packet
 *
 *  @return new LBPacket whose data represents a concatenation of the above two data packets
 */
- (nonnull instancetype)combineWithPacket:(nonnull LBPacket*)packet;

/*!
 *  Returns a packet that contains a subset of the data in the receiver, as specified by the range.
 *
 *  @param range range of bytes from the receiver to place into the new packet
 *
 *  @return new instance of packet with a subset of receiver's data
 *  @throws NSRangeException if range exceeds the limit of the receiver's data
 */
- (nonnull instancetype)subPacketWithRange:(NSRange)range;

/**
 *  Copies a range of bytes from the receiver’s data into a given buffer and returns the same object as a convenience.
 *
 *  @param buffer   A buffer into which to copy data.
 *  @param location The starting location of which to start reading data. Must lie within [0 ... n-1], where n is the data length. Once the data is read, the location will increment by the number of bytes written.
 *  @param length   Number of bytes to read into buffer
 *
 *  @return buffer - the same buffer that is passed in as input
 *  @throws NSRangeException - attempting to read from a location in data that is beyond data.length
 */
- (nonnull void*)getBytes:(nonnull void*)buffer startingFrom:(nonnull NSUInteger*)location length:(NSUInteger)length;

/**
 *  Chunks the packet down to N <MTU>-byte sized chunks. If the data is not an exact multiple of the MTU, the remaining bytes will be zero-padded to fit into an MTU.
 *
 *  @return Array of chunks of the data, all data objects are <MTU>-byte sized chunks
 */
- (nonnull NSArray<NSData*>*)chunks;

@end



/**
 *  Reading Values Convenience Methods - essentially call `getBytes:startingFrom:length:`
 */
@interface LBPacket (LBPacketReadingValues)

- (nonnull NSData*)readDataFrom:(nonnull NSUInteger*)byteLocation length:(NSUInteger)length;

- (BOOL)readBoolFrom:(nonnull NSUInteger*)byteLocation;

- (int8_t)readInt8From:(nonnull NSUInteger*)byteLocation;
- (int16_t)readInt16From:(nonnull NSUInteger*)byteLocation;
- (int32_t)readInt32From:(nonnull NSUInteger*)byteLocation;
- (int64_t)readInt64From:(nonnull NSUInteger*)byteLocation;

- (uint8_t)readUInt8From:(nonnull NSUInteger*)byteLocation;
- (uint16_t)readUInt16From:(nonnull NSUInteger*)byteLocation;
- (uint32_t)readUInt32From:(nonnull NSUInteger*)byteLocation;
- (uint64_t)readUInt64From:(nonnull NSUInteger*)byteLocation;

- (float)readFloat16From:(nonnull NSUInteger*)byteLocation;
- (float)readFloat32From:(nonnull NSUInteger*)byteLocation;
- (float)readFloat64From:(nonnull NSUInteger*)byteLocation;

/**
 *  Reads a 10.6 fixed point time interval from the packet
 *
 *  @param byteLocation The location in the packet data from where to start reading from
 *
 *  @return NSTimeInterval
 */
- (NSTimeInterval)readTimeIntervalStartingFrom:(nonnull NSUInteger*)byteLocation;

@end
