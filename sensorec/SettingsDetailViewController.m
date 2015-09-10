//
//  SettingsDetailViewController.m
//  sensorec
//
//  Created by Niladri Bora on 9/9/15.
//  Copyright © 2015 AHN. All rights reserved.
//

#import "SettingsDetailViewController.h"
#import "CoachV2.h"

@interface SettingsDetailViewController()<UITextFieldDelegate>

@end

@implementation SettingsDetailViewController{
    @private
    CoachV2* _coach;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _coach = [CoachV2 sharedInstance];
    self.minValue = [_coach valueForKey:[NSString stringWithFormat:@"%@Min",
                                        self.parameterName.lowercaseString]];
    self.maxValue = [_coach valueForKey:[NSString stringWithFormat:@"%@Max",
                                         self.parameterName.lowercaseString]];
    self.minField.text = [self.minValue description];
    self.maxField.text = [self.maxValue description];
    self.minField.delegate = self;
    self.maxField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClickSave:(id)sender {
    [_coach setValue:@(self.minField.text.integerValue)
             forKey:[NSString stringWithFormat:@"%@Min",
                     self.parameterName.lowercaseString]];
    [_coach setValue:@(self.maxField.text.integerValue)
             forKey:[NSString stringWithFormat:@"%@Max",
                     self.parameterName.lowercaseString]];
    [_coach writeSettings];
}

- (IBAction)onClickClose:(id)sender {
    [_coach writeSettings];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
