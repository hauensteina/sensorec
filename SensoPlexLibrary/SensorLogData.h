//
//  SensorLogData.h
//  Sensoplex
//
//  Created by Maciej Czupryna on 20.12.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import "SensorData.h"

@interface SensorLogData : SensorData

@property (nonatomic, assign) long recNumber;

// defines which data are logged
@property (nonatomic, assign) int sensorLogMask;

// defines type of logged data (0..2)
@property (nonatomic, assign) int typeId;

@end
