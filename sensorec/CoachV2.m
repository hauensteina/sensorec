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
        [self.js evaluateScript:jsStr];
        //Override LOG to print to console
        self.js[@"LOG"] = ^(NSString* s){
            NSLog(@"%@", s);
        };
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
    
}

-(void) writeSettings{
    
}

@end
