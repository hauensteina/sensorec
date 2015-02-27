//
//  cfuncs.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-10.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cfuncs.h"

//--------------------------------
void PDATA (char *p_format, ...)
//--------------------------------
// Redirect PDATA as used on the sensor to NSLog
{
    char buf[1000];
    va_list args;
    va_start(args, p_format);
    vsprintf (buf, p_format, args);
    va_end (args);
    NSLog(@"%s",buf);
} // PDATA

