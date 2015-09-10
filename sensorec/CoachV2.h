//
//  CoachV2.h
//  sensorec
//
//  Created by Niladri Bora on 9/2/15.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RealtimeCoachDelegate <NSObject>

-(void) onTipsReciept:(NSArray*) tips;

@end

@interface CoachV2 : NSObject

@property(weak, nonatomic, readwrite) id<RealtimeCoachDelegate> delegate;

@property(assign, nonatomic) float bounceMin;
@property(assign, nonatomic) float bounceMax;

@property(assign, nonatomic) float cadenceMin;
@property(assign, nonatomic) float cadenceMax;

@property(assign, nonatomic) float lurchMin;
@property(assign, nonatomic) float lurchMax;

@property(assign, nonatomic) float plodMin;
@property(assign, nonatomic) float plodMax;

@property(assign, nonatomic) float rotxMin;
@property(assign, nonatomic) float rotxMax;

@property(assign, nonatomic) float rotyMin;
@property(assign, nonatomic) float rotyMax;

@property(assign, nonatomic) float rotzMin;
@property(assign, nonatomic) float rotzMax;


@property(assign, nonatomic) NSInteger sampleSize;

+(instancetype) sharedInstance;

-(void) endRun;

-(NSArray*) addDataPoint:(NSDictionary*) pt;

-(void) readSettings;

-(void) writeSettings;

@end
