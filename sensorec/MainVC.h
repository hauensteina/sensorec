//
//  MainVC.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController <NSStreamDelegate, UITextFieldDelegate>

- (void) setLogStatus:(NSString *)status
                 used:(NSString *)usedBytes
                total:(NSString *)totalBytes
              records:(NSString *)nRecords;

@end
