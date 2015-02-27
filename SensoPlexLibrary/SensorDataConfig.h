//
//  SensorConfigData.h
//  Sensoplex
//
//  Created by Maciej Czupryna on 11.12.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorDataAbstract.h"

@interface SensorDataConfig : SensorDataAbstract
@property (nonatomic, copy) NSString *boardAddress;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) int options;
@end
