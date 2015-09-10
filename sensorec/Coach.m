//
//  Coach.m
//  sensorec
//
//  Created by Niladri Bora on 8/6/15.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "Coach.h"

@interface Coach ()

//Data structures to store historical and avergage values of sensor properties
@property(strong, nonatomic) NSMutableArray* cadenceValues;
@property(strong, nonatomic) NSMutableArray* bounceValues;
@property(strong, nonatomic) NSMutableArray* lurchValues;
@property(strong, nonatomic) NSMutableArray* plodValues;
@property(strong, nonatomic) NSMutableArray* rotxValues;
@property(strong, nonatomic) NSMutableArray* rotyValues;
@property(strong, nonatomic) NSMutableArray* rotzValues;

@property(assign, nonatomic) double avgCadence;
@property(assign, nonatomic) double avgBounce;
@property(assign, nonatomic) double avgLurch;
@property(assign, nonatomic) double avgPlod;
@property(assign, nonatomic) double avgRotx;
@property(assign, nonatomic) double avgRoty;
@property(assign, nonatomic) double avgRotz;

@end

@implementation Tip

@end

@implementation Coach

+(instancetype) sharedInstance{
    static Coach* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [Coach new];
        [sharedInstance readSettings];
    });
    return sharedInstance;
}

-(instancetype) init
{
    self = [super init];
    if(self){
        _cadenceValues = [NSMutableArray new];
        _bounceValues = [NSMutableArray new];
        _lurchValues = [NSMutableArray new];
        _plodValues = [NSMutableArray new];
        _rotxValues = [NSMutableArray new];
        _rotyValues = [NSMutableArray new];
        _rotzValues = [NSMutableArray new];
    }
    return self;
}


-(NSArray*) getCoachingTips:(NSDictionary*) dataPoint
{
    NSMutableArray* tips = [NSMutableArray new];
    [self.cadenceValues addObject:dataPoint[CADENCE]];
    [self.bounceValues addObject:dataPoint[BOUNCE]];
    [self.lurchValues addObject:dataPoint[LURCH]];
    [self.plodValues addObject:dataPoint[PLOD]];
    [self.rotxValues addObject:dataPoint[ROTX]];
    [self.rotyValues addObject:dataPoint[ROTY]];
    [self.rotzValues addObject:dataPoint[ROTZ]];
    if(self.cadenceValues.count< self.sampleSize)
        return nil;
    
    self.avgCadence = [self calculateAvg:self.cadenceValues];
    self.avgBounce = [self calculateAvg:self.bounceValues];
    self.avgLurch = [self calculateAvg:self.lurchValues];
    self.avgPlod = [self calculateAvg:self.plodValues];
    self.avgRotx = [self calculateAvg:self.rotxValues];
    self.avgRoty = [self calculateAvg:self.rotyValues];
    self.avgRotz = [self calculateAvg:self.rotzValues];
    //if the min and max are the same that means that there is threshold for this parameter
    @try {
        if(self.bounceMin != self.bounceMax){
            if(self.avgBounce < self.bounceMin){
                Tip* tip = [Tip new];
                tip.visualTip = [NSString stringWithFormat:@"Your avg. bounce %d is too low."
                                 @"Increase bounce!", (int)self.avgBounce];
                tip.audioTip = @"Increase bounce.";
                tip.tipColor = [UIColor redColor];
                [tips addObject:tip];
            }
            else if(self.avgBounce > self.bounceMax){
                Tip* tip = [Tip new];
                tip.visualTip = [NSString stringWithFormat:@"Your avg. bounce %d is too high."
                                 @"Decrease bounce!", (int)self.avgBounce];
                tip.audioTip = @"Decrease bounce.";
                tip.tipColor = [UIColor redColor];
                [tips addObject:tip];
            }
            if(tips.count > 0)
                return tips;
        }
        
        if(self.cadenceMin != self.cadenceMax){
            if(self.avgCadence < self.cadenceMin){
                Tip* tip = [Tip new];
                tip.visualTip = [NSString stringWithFormat:@"Your avg. cadence %d is too low. "
                                 @"Increase cadence", (int)self.avgCadence];
                tip.audioTip = @"Increase cadence";
                tip.tipColor = [UIColor redColor];
                [tips addObject:tip];
            }
            else if(self.avgCadence > self.cadenceMax){
                Tip* tip = [Tip new];
                tip.visualTip = [NSString stringWithFormat:@"Your avg. cadence %d is too high. "
                                 @"Decrease cadence", (int)self.avgCadence];
                tip.audioTip = @"Decrease cadence";
                tip.tipColor = [UIColor redColor];
                [tips addObject:tip];
            }
            if(tips.count > 0)
                return tips;
            
        }
        
        if(tips.count == 0){
            Tip* tip = [Tip new];
            tip.tipColor = [UIColor greenColor];
            tip.visualTip = @"You are doing great";
            [tips addObject:tip];
            return tips;
        }
        
    }
    @finally {
        //clear out samples
        [self.cadenceValues removeAllObjects];
        [self.bounceValues removeAllObjects];
        [self.lurchValues removeAllObjects];
        [self.plodValues removeAllObjects];
        [self.rotxValues removeAllObjects];
        [self.rotyValues removeAllObjects];
        [self.rotzValues removeAllObjects];
    }
    
    

}

-(double) calculateAvg:(NSArray*) dataPoints
{
    if(dataPoints.count==0)
        return 0;
    double total = 0;
    for(NSNumber* value in dataPoints){
        total += value.floatValue;
    }
    return total/dataPoints.count;
}













@end
