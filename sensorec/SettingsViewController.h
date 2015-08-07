//
//  SettingsViewController.h
//  sensorec
//
//  Created by Niladri Bora on 8/7/15.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *minBounceLabel;
@property (weak, nonatomic) IBOutlet UITextField *maxBounceLabel;
@property (weak, nonatomic) IBOutlet UITextField *minCadenceLabel;
@property (weak, nonatomic) IBOutlet UITextField *maxCadenceLabel;

-(IBAction)onSave:(id)sender;


-(IBAction)onClose:(id)sender;

@end
