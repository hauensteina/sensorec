//
//  common.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-19.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#ifndef sensorec_common_h
#define sensorec_common_h

#import <UIKit/UIColor.h>
#import "AppDelegate.h"

extern AppDelegate *g_app;

#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


#define RGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RM_SUBVIEWS(x) \
  for(UIView *v in (x).subviews) { \
     [v removeFromSuperview]; \
  }

#endif


