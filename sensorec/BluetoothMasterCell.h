//
//  BluetoothMasterCell.h
//  Sensoplex
//
//  Created by Maciej Czupryna on 08.11.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BluetoothMasterCell : UITableViewCell
@property (nonatomic, readonly) UILabel *label1;
@property (nonatomic, readonly) UILabel *label2;
@property (nonatomic, readonly) UILabel *label3;
@property (nonatomic, readonly) UILabel *label4;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL drawBorder;
@end
