//
//  common.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-19.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#ifndef sensorec_common_h
#define sensorec_common_h

#import "AppDelegate.h"

extern AppDelegate *g_app;

#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#endif
