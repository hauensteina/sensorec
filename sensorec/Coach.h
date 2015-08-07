//
//  Coach.h
//  sensorec
//
//  Created by Niladri Bora on 8/6/15.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CADENCE @"Cadence"
#define BOUNCE @"Bounce"
#define LURCH @"Lurch"
#define PLOD @"Plod"
#define ROTX @"Rotx"
#define ROTY @"Roty"
#define ROTZ @"Rotz"

@interface Tip : NSObject

@property(strong, nonatomic) NSString* audioTip;
@property(strong, nonatomic) NSString* visualTip;
@property(strong, nonatomic) UIColor* tipColor;

@end

@interface Coach : NSObject

@property(assign, nonatomic) NSInteger bounceMin;
@property(assign, nonatomic) NSInteger bounceMax;
@property(assign, nonatomic) NSInteger cadenceMin;
@property(assign, nonatomic) NSInteger cadenceMax;

+(instancetype) sharedInstance;

-(NSArray*) getCoachingTips:(NSDictionary*) dataPoint;

-(void) readSettings;

-(void) writeSettings;

@end
