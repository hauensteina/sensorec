//
//  BrickVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-06-16.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

//--------------------------------------
@interface BrickVC : UIViewController
//--------------------------------------

- (void) animateQuaternion:(NSArray*)p_q;
- (void) fusionOS;
- (void) fusionFU;
// State properties
@property enum {NONE,OS,FU} fusionType;
@property float corrAngle;

// UI properties
@property (weak, nonatomic) IBOutlet UIButton *btnFU;
@property (weak, nonatomic) IBOutlet UIButton *btnOS;

@end // BrickVC

