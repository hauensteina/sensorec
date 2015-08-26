//
//  LBSDBCommand.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 8/17/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBCommand.h"

@interface LBSDBCommand : LBCommand
@property (strong, nonatomic, nonnull, readonly) NSData* selfDescriptiveBinary;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
