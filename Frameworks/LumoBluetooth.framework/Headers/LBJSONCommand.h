//
//  LBJSONCommand.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/18/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//
//  TODO: Sending ack message back

#import "LBCommand.h"

@interface LBJSONCommand : LBCommand
@property (copy, nonatomic, nonnull, readonly) NSString* jsonString;

- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a JSON command with the given json string. The json string is sent "as-is" with no modification
 *
 *  @param jsonString string representing a properly formatted JSON object to be sent to the PRM
 *
 *  @return JSON command object with jsonString encoded
 */
- (nonnull instancetype)initWithJSON:(nonnull NSString*)jsonString;

/**
 *  Initializes as JSON command with the command string, and properly formats it for the PRM to understand.
 *
 *  @param commandString command string to send, such as "BSE_GET" or "BSE_SET:10"
 *
 *  @return JSON command object with jsonString encoded
 */
- (nonnull instancetype)initWithCommandString:(nonnull NSString*)commandString;

/**
 *  Initializes a JSON command with a specific command and list of arguments
 *
 *  @param command   string representation of a command that the PRM responds to
 *  @param arguments strings that should be sent with the command; nil if no arguments
 *
 *  @return JSON command object to send to the sensor
 */
- (nonnull instancetype)initWithCommand:(nonnull NSString*)command arguments:(nullable NSArray<NSString*>*)arguments;

@end
