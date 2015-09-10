//
//  CoachV2.m
//  sensorec
//
//  Created by Niladri Bora on 9/2/15.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "CoachV2.h"
#import "Coach.h"

@import JavaScriptCore;

@interface CoachV2 ()
@property(strong,nonatomic) JSContext* js;
@end

@implementation CoachV2

+(instancetype) sharedInstance{
    static CoachV2* sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CoachV2 new];
        [sharedInstance readSettings];
    });
    return sharedInstance;
}

//designated initializer
-(instancetype) init{
    self = [super init];
    if(self){
        NSString* path = [[NSBundle mainBundle] pathForResource:@"coach"
                                                         ofType:@"js"];
        NSString* jsStr = [[NSString alloc]
                           initWithData:[NSData dataWithContentsOfFile:path]
                           encoding:NSUTF8StringEncoding];
        self.js = [JSContext new];
        [self.js setExceptionHandler:^(JSContext * ctx, JSValue * val) {
            NSLog(@"%@", val);
        }];
        //Override LOG to print to console
        self.js[@"LOG"] = ^(NSString* s){
            NSLog(@"%@", s);
        };
        [self.js evaluateScript:jsStr];
    }
    return self;
}

-(void) endRun{
    
}

/**
 {
 't': 10,
 'cadence': 111.11,
 'bounce': 222.22,
 'lurch': 333.33,
 'pelvic_rot_x': 10,
 'pelvic_rot_y': 0,
 'pelvic_rot_z': 0,
 'stride': 555.55,
 'ground_contact_t': 666.66
 }
 */
-(NSArray*) addDataPoint:(NSDictionary*) pt{
    NSMutableDictionary* jsInput = [NSMutableDictionary new];
    jsInput[@"cadence"] = pt[CADENCE];
    jsInput[@"bounce"] = pt[BOUNCE];
    jsInput[@"lurch"] = pt[LURCH];
    jsInput[@"ground_contact_t"] = pt[PLOD];
    jsInput[@"pelvic_rot_x"] = pt[ROTX];
    jsInput[@"pelvic_rot_y"] = pt[ROTY];
    jsInput[@"pelvic_rot_z"] = pt[ROTZ];
    jsInput[@"stride"] = @0;
    jsInput[@"t"] = @([[NSDate date] timeIntervalSince1970]);
    
//    JSValue* m = [self.js evaluateScript:@"run_data_mgr.addDataPoint"];
//    NSArray* tips = [[m callWithArguments:@[jsInput]] toArray];
    JSValue* m = [self.js evaluateScript:@"run_data_mgr"];
    NSArray* tips= [[m invokeMethod:@"addDataPoint" withArguments:@[jsInput]]
                    toArray];
    NSMutableArray* retVals =[NSMutableArray new];
    for(NSString* t in tips){
        Tip* tip = [Tip new];
        tip.audioTip = t;
        tip.visualTip = t;
        tip.tipColor = [UIColor greenColor];
        [retVals addObject:tip];
    }
    return retVals;
}

-(void) readSettings{
    self.bounceMin = [[NSUserDefaults standardUserDefaults] floatForKey:BOUNCE_MIN_KEY];
    if(self.bounceMin == 0)
        self.bounceMin = BOUNCE_MIN;
    self.bounceMax = [[NSUserDefaults standardUserDefaults] floatForKey:BOUNCE_MAX_KEY];
    if(self.bounceMax == 0)
        self.bounceMax = BOUNCE_MAX;
    
    self.cadenceMin = [[NSUserDefaults standardUserDefaults] floatForKey:CADENCE_MIN_KEY];
    if(self.cadenceMin == 0)
        self.cadenceMin = CADENCE_MIN;
    self.cadenceMax = [[NSUserDefaults standardUserDefaults] floatForKey:CADENCE_MAX_KEY];
    if(self.cadenceMax == 0)
        self.cadenceMax = CADENCE_MAX;

    self.cadenceMin = [[NSUserDefaults standardUserDefaults] floatForKey:CADENCE_MIN_KEY];
    if(self.cadenceMin == 0)
        self.cadenceMin = CADENCE_MIN;
    self.cadenceMax = [[NSUserDefaults standardUserDefaults] floatForKey:CADENCE_MAX_KEY];
    if(self.cadenceMax == 0)
        self.cadenceMax = CADENCE_MAX;

    self.lurchMin = [[NSUserDefaults standardUserDefaults] floatForKey:LURCH_MIN_KEY];
    if(self.lurchMin == 0)
        self.lurchMin = LURCH_MIN;
    self.lurchMax = [[NSUserDefaults standardUserDefaults] floatForKey:LURCH_MAX_KEY];
    if(self.lurchMax == 0)
        self.lurchMax = LURCH_MAX;

    self.plodMin = [[NSUserDefaults standardUserDefaults] floatForKey:PLOD_MIN_KEY];
    if(self.plodMin == 0)
        self.plodMin = PLOD_MIN;
    self.plodMax = [[NSUserDefaults standardUserDefaults] floatForKey:PLOD_MAX_KEY];
    if(self.plodMax == 0)
        self.plodMax = PLOD_MAX;
    
    self.rotxMin = [[NSUserDefaults standardUserDefaults] floatForKey:ROTX_MIN_KEY];
    if(self.rotxMin == 0)
        self.rotxMin = ROTX_MIN;
    self.rotxMax = [[NSUserDefaults standardUserDefaults] floatForKey:ROTX_MAX_KEY];
    if(self.rotxMax == 0)
        self.rotxMax = ROTX_MAX;
    
    self.rotyMin = [[NSUserDefaults standardUserDefaults] floatForKey:ROTY_MIN_KEY];
    if(self.rotyMin == 0)
        self.rotyMin = ROTY_MIN;
    self.rotyMax = [[NSUserDefaults standardUserDefaults] floatForKey:ROTY_MAX_KEY];
    if(self.rotyMax == 0)
        self.rotyMax = ROTY_MAX;
    
    self.rotzMin = [[NSUserDefaults standardUserDefaults] floatForKey:ROTZ_MIN_KEY];
    if(self.rotzMin == 0)
        self.rotzMin = ROTZ_MIN;
    self.rotyMax = [[NSUserDefaults standardUserDefaults] floatForKey:ROTY_MAX_KEY];
    if(self.rotzMax == 0)
        self.rotzMax = ROTZ_MAX;
    
    self.sampleSize= [[NSUserDefaults standardUserDefaults] integerForKey:SAMPLE_SIZE_KEY];
    if(self.sampleSize == 0)
        self.sampleSize = AVG_SAMPLE_SIZE;
}

-(void) writeSettings{
    [[NSUserDefaults standardUserDefaults] setFloat:self.bounceMin forKey:BOUNCE_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.bounceMax forKey:BOUNCE_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setFloat:self.cadenceMin forKey:CADENCE_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.cadenceMax forKey:CADENCE_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMin forKey:PLOD_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMax forKey:PLOD_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMin forKey:LURCH_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMax forKey:LURCH_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMin forKey:ROTX_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMax forKey:ROTX_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMin forKey:ROTY_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMax forKey:ROTY_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMin forKey:ROTZ_MIN_KEY];
    [[NSUserDefaults standardUserDefaults] setFloat:self.plodMax forKey:ROTZ_MAX_KEY];

    [[NSUserDefaults standardUserDefaults] setInteger:self.sampleSize forKey:SAMPLE_SIZE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
