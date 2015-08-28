//
//  BrickVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-06-16.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

//--------------------------------------
@interface BrickVC : UIViewController
//--------------------------------------

- (void) animateQuaternion:(GLKQuaternion)glkq;
@property float corrAngle;


@end // BrickVC

