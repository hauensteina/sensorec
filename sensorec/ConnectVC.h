//
//  ConnectVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-27.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensoPlex.h"

@interface ConnectVC : UIViewController

// the SensoPlex object to work with to interact with the SP-10BN Module
@property (strong, nonatomic, retain) SensoPlex *sensoPlex;

@end
