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

#define CLEAR [UIColor clearColor]
#define WHITE [UIColor whiteColor]
#define BLACK [UIColor blackColor]
#define YELLOW [UIColor yellowColor]
#define RED [UIColor redColor]
#define BLUE [UIColor blueColor]
#define GREEN [UIColor greenColor]
#define GRAY [UIColor grayColor]

// Alpha is inverted. Use like
// UIColor *c = RGB(0x707070)
// for gray with alpha = 1 or
// UIColor *c = RGB(0x80ff0000)
// for red with alpha = 0.5
#define RGB(HHH) [UIColor colorWithRed: (((HHH)>>16)&255)/255.f \
green:(((HHH)>>8)&255)/255.f \
blue: ((HHH)&255)/255.f \
alpha:(255-(((HHH)>>24)&255))/255.f]

#define RM_SUBVIEWS(x) \
  for(UIView *v in (x).subviews) { \
     [v removeFromSuperview]; \
  }

#endif


