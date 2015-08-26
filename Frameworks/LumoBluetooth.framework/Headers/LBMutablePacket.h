//
//  LBMutablePacket.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 6/27/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBPacket.h"

@interface LBMutablePacket : LBPacket
@property (copy, nonatomic, nonnull, readwrite) NSData* data;

/**
 *  This method will automatically convert host bytes of primitive types to the specified byte order of the packet and append them to the existing data.
 *  Do NOT use this for struct representations; you must go through each primitive type in the struct and append them individually.
 *
 *  @param bytes  byte array whose byte order is in host machine order, and can switch endian-ness depending on how the packet is configured.
 *  @param length length of the byte array
 */
- (void)appendBytes:(nonnull const void*)bytes length:(NSUInteger)length;

/**
 *  Replaces the receiver's bytes in the specified range with the bytes given.
 *
 *  @param range range of bytes to replace in the receiver
 *  @param bytes bytes to replace with
 */
- (void)replaceBytesAt:(NSRange)range withBytes:(nonnull const void*)bytes;

/**
 *  Returns a copy of the packet data as a MutableData array. You must save this data back to the data variable if you want the packet
 *  store any changes
 *
 *  @return copy of data in an NSMutableData container
 */
- (nonnull NSMutableData*)mutableData;

/**
 *  Refreshes the packet with current data. Should be overriden in subclasses. Does Nothing in base class.
 */
- (void)refreshPacket;

/**
 *  Clears all data from the packet
 */
- (void)clearData;

@end



@interface LBMutablePacket (LBMutablePacketWritingValues)

/**
 *  Appends the data to the receiver, `data` byte order is NOT changed as it is not a value representation
 *
 *  @param data <#data description#>
 */
- (void)appendData:(nonnull NSData*)data;

/**
 *  Appends the values to the packet according to the receiver's preferred byte order
 *
 *  @param value typed value
 */
- (void)appendInt8:(int8_t)value;
- (void)appendInt16:(int16_t)value;
- (void)appendInt32:(int32_t)value;
- (void)appendInt64:(int64_t)value;

- (void)appendUInt8:(uint8_t)value;
- (void)appendUInt16:(uint16_t)value;
- (void)appendUInt32:(uint32_t)value;
- (void)appendUInt64:(uint64_t)value;

- (void)appendFloat16:(float)value;

/**
 *  Converts a subsecond time interval to a fixed, 6 byte representation, and adds it to the existing data packet in the specified byte order.
 *
 *  @param timeInterval timeInterval to convert
 *
 */
- (void)appendTimeIntervalInFixedPointFormat:(NSTimeInterval)timeInterval;

@end
