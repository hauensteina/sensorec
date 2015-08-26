//
//  ConnectVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-27.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LumoBluetooth/LumoBluetooth.h>

@interface ConnectVC : UIViewController <UITableViewDelegate>

// the SensoPlex object to work with to interact with the SP-10BN Module
@property (weak, nonatomic) LBPeripheral* peripheral;
@property NSString *mySensoName;
@property BOOL connected;

@end
