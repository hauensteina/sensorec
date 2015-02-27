//
//  SensorDataLogStatus.h
//  Sensoplex
//
//  Created by Maciej Czupryna on 11.12.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorDataAbstract.h"

@interface SensorDataLogStatus : SensorDataAbstract
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) double logNumberOfRecords;
@property (nonatomic, assign) double logUsedBytes;
@property (nonatomic, assign) double logTotalBytes;
@end
