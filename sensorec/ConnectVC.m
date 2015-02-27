//
//  ConnectVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-27.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "ConnectVC.h"
#import "common.h"

@interface ConnectVC ()
@end

@implementation ConnectVC

//-------------------
- (void)viewDidLoad
//-------------------
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//------------------------------
- (IBAction)btnBack:(id)sender
//------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
