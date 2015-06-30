//
//  BlurpVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-06-30.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlurpVC : UIViewController <UIScrollViewDelegate,UINavigationBarDelegate>

// Pass in values to update the sparklines
- (void) cadence:(NSNumber*)cadence
          bounce:(NSNumber*)bounce
           lurch:(NSNumber*)lurch
            plod:(NSNumber*)plod
            rotx:(NSNumber*)rotx
            roty:(NSNumber*)roty
            rotz:(NSNumber*)rotz;

@end
