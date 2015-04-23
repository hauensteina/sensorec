//
//  MainVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController <NSStreamDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UILabel *lbRecords;
@property (weak, nonatomic) IBOutlet UILabel *lbBytes;
@property (weak, nonatomic) IBOutlet UILabel *lbTotal;
@property (weak, nonatomic) IBOutlet UIButton *btnLed;
@property (weak, nonatomic) IBOutlet UILabel *lbRecordsUsed;
@property (weak, nonatomic) IBOutlet UILabel *lbBytesUsed;
@property (weak, nonatomic) IBOutlet UILabel *lbTotlab;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnShutter;

- (void) setLogStatus:(NSString *)status
                 used:(NSString *)usedBytes
                total:(NSString *)totalBytes
              records:(NSString *)nRecords;

@end
