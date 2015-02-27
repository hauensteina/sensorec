//
//  SensorDataAbstract.h
//  Sensoplex
//
//  Created by Maciej Czupryna on 11.12.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface SensorDataAbstract : NSObject
- (NSDictionary*)asDictionary;
- (void)logClass;
@end
