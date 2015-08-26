//
//  LBMintCommand.h
//  LumoBluetooth
//
//  Created by Ragu Vijaykumar on 7/12/15.
//  Copyright © 2015 Lumo BodyTech. All rights reserved.
//

#import "LBCommand.h"

@interface LBMintCommand : LBCommand
@property (strong, nonatomic, nonnull) NSData* softId;  // Must be less than 256 bytes long

@end
