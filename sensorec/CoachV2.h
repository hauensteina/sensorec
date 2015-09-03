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

+(instancetype) sharedInstance;

-(void) endRun;

-(NSArray*) addDataPoint:(NSDictionary*) pt;

-(void) readSettings;

-(void) writeSettings;

@end
