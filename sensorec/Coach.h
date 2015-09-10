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

#define AVG_SAMPLE_SIZE 10

//default thresholds
#define CADENCE_MIN 150
#define CADENCE_MAX 200
#define BOUNCE_MIN 0
#define BOUNCE_MAX 25
#define LURCH_MIN 0
#define LURCH_MAX 0
#define PLOD_MIN 0
#define PLOD_MAX 0
#define ROTX_MIN 0
#define ROTX_MAX 0
#define ROTY_MIN 0
#define ROTY_MAX 0
#define ROTZ_MIN 0
#define ROTZ_MAX 0

//user defaults keys
#define CADENCE_MIN_KEY @"CADENCE_MIN_KEY"
#define CADENCE_MAX_KEY @"CADENCE_MAX_KEY"

#define BOUNCE_MIN_KEY @"BOUNCE_MIN_KEY"
#define BOUNCE_MAX_KEY @"BOUNCE_MAX_KEY"

#define LURCH_MIN_KEY @"LURCH_MIN_KEY"
#define LURCH_MAX_KEY @"LURCH_MAX_KEY"

#define PLOD_MIN_KEY @"PLOD_MIN_KEY"
#define PLOD_MAX_KEY @"PLOD_MAX_KEY"

#define ROTX_MIN_KEY @"ROTX_MIN_KEY"
#define ROTX_MAX_KEY @"ROTX_MAX_KEY"

#define ROTY_MIN_KEY @"ROTY_MIN_KEY"
#define ROTY_MAX_KEY @"ROTY_MAX_KEY"

#define ROTZ_MIN_KEY @"ROTZ_MIN_KEY"
#define ROTZ_MAX_KEY @"ROTZ_MAX_KEY"

#define SAMPLE_SIZE_KEY @"SAMPLE_SIZE_KEY"




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

@property(assign, nonatomic) NSInteger lurchMin;
@property(assign, nonatomic) NSInteger lurchMax;

@property(assign, nonatomic) NSInteger plodMin;
@property(assign, nonatomic) NSInteger plodMax;

@property(assign, nonatomic) NSInteger rotxMin;
@property(assign, nonatomic) NSInteger rotxMax;

@property(assign, nonatomic) NSInteger rotyMin;
@property(assign, nonatomic) NSInteger rotyMax;

@property(assign, nonatomic) NSInteger rotzMin;
@property(assign, nonatomic) NSInteger rotzMax;

@property(assign, nonatomic) NSInteger sampleSize;

+(instancetype) sharedInstance;

-(NSArray*) getCoachingTips:(NSDictionary*) dataPoint;

-(void) readSettings;

-(void) writeSettings;

@end
