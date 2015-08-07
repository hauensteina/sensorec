//
//  SettingsViewController.m
//  sensorec
//
//  Created by Niladri Bora on 8/7/15.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "SettingsViewController.h"
#import "Coach.h"

@interface SettingsViewController()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Coach* coach = [Coach sharedInstance];
    self.minBounceLabel.text = @(coach.bounceMin).description;
    self.maxBounceLabel.text= @(coach.bounceMax).description;
    self.minCadenceLabel.text= @(coach.cadenceMin).description;
    self.maxCadenceLabel.text= @(coach.cadenceMax).description;
    [self.minBounceLabel setReturnKeyType:UIReturnKeyDone];
    [self.maxBounceLabel setReturnKeyType:UIReturnKeyDone];
    [self.minCadenceLabel setReturnKeyType:UIReturnKeyDone];
    [self.maxCadenceLabel setReturnKeyType:UIReturnKeyDone];
    self.minBounceLabel.delegate = self;
    self.maxBounceLabel.delegate = self;
    self.minCadenceLabel.delegate = self;
    self.maxCadenceLabel.delegate = self;
//    self.minBounceLabel.keyboardType = UIKeyboardTypeDecimalPad;
//    self.maxBounceLabel.keyboardType = UIKeyboardTypeDecimalPad;
//    self.minCadenceLabel.keyboardType = UIKeyboardTypeDecimalPad;
//    self.maxCadenceLabel.keyboardType = UIKeyboardTypeDecimalPad;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onSave:(id)sender
{
    Coach* coach = [Coach sharedInstance];
    coach.bounceMin = self.minBounceLabel.text.integerValue;
    coach.bounceMax = self.maxBounceLabel.text.integerValue;
    coach.cadenceMin = self.minCadenceLabel.text.integerValue;
    coach.cadenceMax = self.maxCadenceLabel.text.integerValue;
    [coach writeSettings];
}


-(IBAction)onClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate methods
//-(void) textFieldDidEndEditing:(UITextField *)textField{
//    [textField resignFirstResponder];
//}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
