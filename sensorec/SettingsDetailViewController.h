//
//  SettingsDetailViewController.h
//  sensorec
//
//  Created by Niladri Bora on 9/9/15.
//  Copyright © 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsDetailViewController : UIViewController
@property(strong, nonatomic, nonnull) NSString* parameterName;
@property(strong, nonatomic, nonnull) NSNumber* minValue;
@property(strong, nonatomic, nonnull) NSNumber* maxValue;

@property (weak, nonatomic) IBOutlet UITextField *minField;
@property (weak, nonatomic) IBOutlet UITextField *maxField;
- (IBAction)onClickSave:(id _Nonnull)sender;
- (IBAction)onClickClose:(id _Nonnull)sender;

@end
