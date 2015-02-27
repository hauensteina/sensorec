//
//  SensorDataLogStreamConfig.h
//  Sensoplex
//
//  Created by Maciej Czupryna on 12.12.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import "SensorDataAbstract.h"

@interface SensorDataLogStreamConfig : SensorDataAbstract
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) int enabledSensorsMask;
@property (nonatomic, assign) int interval;
@end
