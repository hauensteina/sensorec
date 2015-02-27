//
//  MainVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-01-13.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "MainVC.h"
#import "common.h"
#import "Utils.h"
#import "prm.h"
#import <CoreMotion/CMMotionManager.h>
#import <AudioToolbox/AudioToolbox.h>
#import <math.h>
#import <stdint.h>

// Vertical displacement with time and length in ticks
//================================
@interface Displacement:NSObject
//================================
@property float displ;
@property int t;
@property int len;
@end

@implementation Displacement
@end

// Streams for socket communication with server
CFReadStreamRef mReadStream = nil;
CFWriteStreamRef mWriteStream = nil;
NSInputStream *mIStream = nil;
NSOutputStream *mOStream = nil;
//=====================
@interface MainVC ()
//=====================

// UI Elements
//---------------
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// Rot matrix to normalize orientation
@property LP_matrix rot;

// Displacement history queue. Holds obj of type Displacement.
@property NSMutableArray *qDisplacement;

// Timeout if no motion, recalibrate
@property NSTimer *tmCalib;

// User Acceleration (motion)
@property (weak, nonatomic) IBOutlet UILabel *lbUsrAccX;
@property (weak, nonatomic) IBOutlet UILabel *lbUsrAccY;
@property (weak, nonatomic) IBOutlet UILabel *lbUsrAccZ;

// Gravity (static)
@property CMAcceleration gravity;
@property CMAcceleration gravityNormalized;
@property CMAcceleration userAcc;
@property float accNorm;
@property (weak, nonatomic) IBOutlet UILabel *lbGravX;
@property (weak, nonatomic) IBOutlet UILabel *lbGravY;
@property (weak, nonatomic) IBOutlet UILabel *lbGravZ;

// Server Connection info
@property (weak, nonatomic) IBOutlet UITextField *txtIPA;
@property (weak, nonatomic) IBOutlet UITextField *txtIPB;
@property (weak, nonatomic) IBOutlet UITextField *txtIPC;
@property (weak, nonatomic) IBOutlet UITextField *txtIPD;
@property (weak, nonatomic) IBOutlet UITextField *txtPort;

@property (weak, nonatomic) IBOutlet UIButton *btnLED;


// Motion stuff
//--------------

@property NSOperationQueue *deviceQueue;
@property CMMotionManager *motionManager;

// Other
//-------

@property NSTimer *connectTimeout;
@property BOOL isConnected;
@property int t_cutoff; // Ignore samples before t_cutoff
@property int t_prev_bad; // Most recent bad lift
@property int t_prev_good; // Most recent good lift
@property BOOL need_calib;
//@property enum {USE_FUSION, USE_GRAVITY, USE_ACCELEROMETER} mode;

// Sounds
//----------------------
@property SystemSoundID badSound;
@property SystemSoundID goodSound;
@property SystemSoundID moreUpSound;
@property SystemSoundID moreDownSound;
@property SystemSoundID backStraightSound;

@end

//======================
@implementation MainVC
//======================

#pragma  mark View LifeCycle

//---------------------
- (void)viewDidLoad
//---------------------
{
    NSURL *soundURL;
    soundURL = [[NSBundle mainBundle] URLForResource:@"badsound"
                                              withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_badSound);

    soundURL = [[NSBundle mainBundle] URLForResource:@"goodsound"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_goodSound);

    soundURL = [[NSBundle mainBundle] URLForResource:@"more_up"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_moreUpSound);

    soundURL = [[NSBundle mainBundle] URLForResource:@"more_down"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_moreDownSound);
    
    soundURL = [[NSBundle mainBundle] URLForResource:@"backstraight"
                                       withExtension:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_backStraightSound);
    
    
    
    [super viewDidLoad];
    
    //_mode = USE_FUSION;
    _need_calib = YES;
    [self initRot];
    _qDisplacement = [NSMutableArray new];
    //angle_test();
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    [_txtIPA setDelegate:self];
    [_txtIPB setDelegate:self];
    [_txtIPC setDelegate:self];
    [_txtIPD setDelegate:self];
    [_txtPort setDelegate:self];
    [self initIP];
    
    _tmCalib =
    [NSTimer scheduledTimerWithTimeInterval:CALIBTIMEOUT
                                     target:self
                                   selector:@selector(tmCalib:)
                                   userInfo:nil
                                    repeats:YES];
        
    // Motion manager
    _deviceQueue = [[NSOperationQueue alloc] init];
    _motionManager = [CMMotionManager new];
    if (_motionManager.isDeviceMotionAvailable) {
        _motionManager.deviceMotionUpdateInterval = 1.0 / SAMPLE_RATE;
        [self.motionManager
         startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
         //startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
         //startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical
         //startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical
         toQueue:self.deviceQueue
         withHandler:^(CMDeviceMotion *m, NSError *error)
         {
             [[NSOperationQueue mainQueue]
              addOperationWithBlock:^{ [self processSample:m]; }];
         }]; // motionmanager
    } // if (motion available)
} // viewDidLoad()

//------------------------------------------
- (void) processSample:(CMDeviceMotion *)m
//------------------------------------------
{
    g_count++;
    
    _userAcc.x = -m.userAcceleration.x;
    _userAcc.y = -m.userAcceleration.z; // note the swap
    _userAcc.z = -m.userAcceleration.y;
    _accNorm = sqrt (SQR(_userAcc.x) + SQR(_userAcc.y) + SQR(_userAcc.z));
    
    _gravity.x = -m.gravity.x;
    _gravity.y = -m.gravity.z; // note the swap
    _gravity.z = -m.gravity.y;
    
    [self normalizeGravity];
    [self updateFilters];
    
    // Vertical acccel. Scale to 2048 like on the sensor.
    float vertacc = 2048.0 * [self getVerticalAcceleration];
    [self checkDisplacement:vertacc];
    
    float fbangle =
    getFbangle (_gravityNormalized.x, _gravityNormalized.y ,_gravityNormalized.z);
    float lrangle =
    getLrangle (_gravityNormalized.x, _gravityNormalized.y ,_gravityNormalized.z);
    angle (LP_PUSH,0,0,fbangle,lrangle,NULL); // Angle history
    
    if (ABS (lrangle) > 40 ) {
        _t_cutoff = g_count;
        _need_calib = YES;
    }
    
    // Do not calibrate if large angle change in prev 4 seconds
    float angle_change;
    angle (LP_GET_ANGLE_CHANGE,-4*SAMPLE_RATE,0,0,0,&angle_change);

    // Do not calibrate if rotating, accelerating, or flat
    if ( angle_change > 20 || ABS(_gravity.x) < 0.6 || _accNorm > 0.2) {
        [self restartTmCalib];
    }
    
    if ([self checkBadLift]) {
        [self playBadSound];
    }
    float smallestAngle = 0;
    if ([self checkGoodLift:&smallestAngle]) {
        NSLog(@"SA:%.2f",smallestAngle);
        if (smallestAngle > 50) {
            [self playGoodSound];
        } else {
            [self playStraightSound];
        }
    }
    
    if (g_count % SAMPLE_RATE == 0) {
        _lbUsrAccX.text = nsprintf (@"%.2f", _userAcc.x);
        _lbUsrAccY.text = nsprintf (@"%.2f", _userAcc.y);
        _lbUsrAccZ.text = nsprintf (@"%.2f", _userAcc.z);
        
        _lbGravX.text = nsprintf (@"%.2f", _gravity.x);
        _lbGravY.text = nsprintf (@"%.2f", _gravity.y);
        _lbGravZ.text = nsprintf (@"%.2f", _gravity.z);
        
    }
    
    if (g_count % SAMPLE_RATE == 0) {
        NSString *msg;
        // Angles
        msg = [self generateJSON:@{@"fbangle":@(fbangle),@"lrangle":@(lrangle)}];
        //NSLog (@"%@",msg);
        if (_isConnected) { [self write2server:msg]; }
        // Motion sensor
        msg = [self generateJSON:@{@"bp":@(g_bp)}];
        //NSLog (@"%@",msg);
        if (_isConnected) { [self write2server:msg]; }
        msg = [self generateJSON:@{@"x":@(_gravityNormalized.x)
                                   ,@"y":@(_gravityNormalized.y)
                                   ,@"z":@(_gravityNormalized.z)}];
        //NSLog (@"%@",msg);
        if (_isConnected) { [self write2server:msg]; }
        msg = [self generateJSON:@{@"xr":@(_gravity.x)
                                   ,@"yr":@(_gravity.y)
                                   ,@"zr":@(_gravity.z)}];
        //NSLog (@"%@",msg);
        if (_isConnected) { [self write2server:msg]; }
    }
} // processSample

//---------------
- (BOOL) silent
//---------------
// Do not play sound unless confident
{
    if ( !_need_calib && (ABS(_gravity.x) > 0.6)) { // && (_accNorm < 0.2) ) {
        return NO;
    }
    return YES;
}

//--------------------------
- (void) playBadSound
//--------------------------
{
    if ([self silent]) return;
    if ([g_app.options[@"sounds"] isEqualToString:@"System"]) {
        [self playSystemSound:@"low_power"];
    }
    else {
        AudioServicesPlaySystemSound (_badSound);
        //AudioServicesPlayAlertSound(_badSound); // also vibrates
    }
}
//--------------------------
- (void) playGoodSound
//--------------------------
{
    if ([self silent]) return;
    if ([g_app.options[@"sounds"] isEqualToString:@"System"]) {
        [self playSystemSound:@"SIMToolkitPositiveACK"];
    }
    else {
        AudioServicesPlaySystemSound (_goodSound);
        //AudioServicesPlayAlertSound(_badSound); // also vibrates
    }
}
//--------------------------
- (void) playStraightSound
//--------------------------
{
    if ([self silent]) return;
    AudioServicesPlaySystemSound (_backStraightSound);
}

#pragma Check for good and bad lifts

//---------------------------------
- (float) getVerticalAcceleration //@@@
//---------------------------------
{
    // Rotate gravity to (0,1,0)
    LP_matrix rot = [self rotUp];
    // Apply gravity direction to external acceleration
    float v_acc[3];
    float v_acc_rot[3];
    v_acc[0] = _userAcc.x;
    v_acc[1] = _userAcc.y;
    v_acc[2] = _userAcc.z;
    matxvec (&rot, v_acc, v_acc_rot);
    return v_acc_rot[1];
} // getVerticalAcceleration

//------------------------------------
- (void) checkDisplacement: (float)vertacc //@@@
//------------------------------------
// Process current sample to check for displacement.
// is there is a displacement, remember it in _qDisplacement.
{
    uint32_t len;
    float disp = lp_displacement (vertacc, 0, &len);
    if (ABS(disp) > 5) { // centimetres
        Displacement *d = [Displacement new];
        d.displ = disp;
        d.t = g_count;
        d.len = len;
        [_qDisplacement addObject:d];
    }
    // Keep only five seconds
    int n = 0;
    for (Displacement *d in _qDisplacement) {
        if (g_count - d.t > 5*SAMPLE_RATE) {
            n++;
        }
        else {
            break;
        }
    } // for
    int i;
    ILOOP(n) {
        [_qDisplacement removeObjectAtIndex:0];
    }
} // checkDisplacement

//-------------------------------
- (Displacement *) getLargestUp
//-------------------------------
// Find largest upwards displacement in qDispl
{
    Displacement *res = nil;
    float maxd = 0;
    for (Displacement *d in _qDisplacement) {
        if (d.displ > maxd) {
            maxd = d.displ;
            res = d;
        }
    }
    return res;
} // getLargestUp

//-------------------------------
- (Displacement *) getLargestDown
//-------------------------------
// Find largest downwards displacement in qDispl
{
    Displacement *res = nil;
    float maxd = 0;
    for (Displacement *d in _qDisplacement) {
        if (d.displ < maxd) {
            maxd = d.displ;
            res = d;
        }
    }
    return res;
} // getLargestDown

//----------------------------------------------
- (Displacement *) getLargestDownBefore:(int)t0
//----------------------------------------------
// Find largest downwards displacement in qDisplacement before t0
{
    Displacement *res = nil;
    float maxd = 0;
    for (Displacement *d in _qDisplacement) {
        if (d.displ < maxd && d.t < t0) {
            maxd = d.displ;
            res = d;
        }
    }
    return res;
} // getLargestDownBefore

//----------------------------------------------
- (Displacement *) getLargestDownAfter:(int)t0
//----------------------------------------------
// Find largest downwards displacement in qDisplacement after t0
{
    Displacement *res = nil;
    float maxd = 0;
    for (Displacement *d in _qDisplacement) {
        if (d.displ < maxd && d.t > t0) {
            maxd = d.displ;
            res = d;
        }
    }
    return res;
} // getLargestDownAfter

//----------------------------------------------
- (Displacement *) getLargestUpAfter:(int)t0
//----------------------------------------------
// Find largest upwards displacement in qDisplacement after t0
{
    Displacement *res = nil;
    float maxd = 0;
    for (Displacement *d in _qDisplacement) {
        if (d.displ > maxd && d.t > t0) {
            maxd = d.displ;
            res = d;
        }
    }
    return res;
} // getLargestDownBefore


#define ABSTIME(r) (g_count + (r))
#define RELTIME(a) ((a) - g_count)


//------------------------
- (BOOL) checkBadLift
//------------------------
// Detect a bad lift
// rt_... are times in the past relative to the present in ticks (-1 = now, -2, -3, ...).
// t_... are absolute times in terms of the tick count g_count.
{
    float smallest_angle;
    int rt_smallest = angle (LP_GET_SMALLEST_ANGLE
                             // ignore stuff before reorient
                             ,MMAX (RELTIME(_t_cutoff), RELTIME (_t_prev_bad))
                             ,LP_NOW
                             ,0
                             ,&smallest_angle);
    float largest_angle;
    int rt_largest = angle (LP_GET_LARGEST_ANGLE
                            ,rt_smallest
                            ,LP_NOW
                            ,0
                            ,&largest_angle);
    BOOL reached_top = NO;
    static float prev_largest_angle;
    if ((largest_angle > smallest_angle)
        && largest_angle - prev_largest_angle < 0.375
        )
    {
        reached_top = YES;
    }
    prev_largest_angle = largest_angle;

    // We don't want to kill a potential good lift
    Displacement *dispDown = [self getLargestDownAfter:_t_cutoff];
    if (dispDown.displ < -10.0) {
        return NO;
    }
    
    int match = 0;
    if (smallest_angle < 50 && smallest_angle > 0) {
        if (largest_angle > 80 && largest_angle < 120) {
            if (reached_top) {
                if (_t_prev_bad != ABSTIME (rt_largest)) {
                    match = 1;
                }
            }
        }
    }
    if (match) {
        _t_prev_bad = ABSTIME (rt_largest);
        _t_cutoff = _t_prev_bad;
        NSString *msg =
        [self generateJSON:@{@"bad_lift":@(1)
                             ,@"ad":@(smallest_angle)
                             ,@"au":@(largest_angle)
                             ,@"dt":@((rt_largest - rt_smallest)/(float)SAMPLE_RATE)
                             ,@"disp":@(0) // @(dispUp.displ)
                             }];
        NSLog (@"%@",msg); if (_isConnected) { [self write2server:msg]; }
        return YES;
    }
    return NO;
} // checkBadLift

//-----------------------------------------------
- (BOOL) checkGoodLift:(float *)smallestAngle
//-----------------------------------------------
// Detect a good lift
{
    static int t_prev_good = 0;
    Displacement *dispDown = [self getLargestDownAfter:_t_cutoff];
    Displacement *dispUp = [self getLargestUpAfter:dispDown.t];
    if (t_prev_good == dispUp.t) { // We already found that one
        return NO;
    }
    
    
    if (!dispDown) {
        //NSLog(@"no disp down");
        return NO;
    }
    if (!dispUp) {
        //NSLog(@"no disp up");
        return NO;
    }
    int match = 0;
#define DISP_DOWN 1
#define DISP_UP (1<<1)
#define ANGLE_UP (1<<2)
#define ALL_MATCHING ((1<<3)-1)
    if (dispDown.displ < -10.0) { // cm
        match |= DISP_DOWN;
    }
    if (dispUp.displ > 10.0) { // cm
        match |= DISP_UP;
    }
//    float angle_down;
//    //angle (LP_GET, RELTIME (dispDown.t),0,0,0,&angle_down);
//    
//    angle (LP_GET_SMALLEST_ANGLE
//           ,RELTIME (dispDown.t - SAMPLE_RATE)
//           ,RELTIME(dispUp.t)
//           ,0,0
//           ,&angle_down);

    //float smallest_angle;
    angle (LP_GET_SMALLEST_ANGLE
           // ignore stuff before reorient
           ,MMAX (RELTIME(_t_cutoff), RELTIME (_t_prev_bad))
           ,LP_NOW
           ,0
           ,smallestAngle);
    
    float angle_up;
    angle (LP_GET, RELTIME (dispUp.t),0,0,0,&angle_up);
    if (angle_up < 120) {
        match |= ANGLE_UP;
    }
    if ((match ^ ALL_MATCHING) == 0) {
        t_prev_good = dispUp.t;
        _t_cutoff = t_prev_good;
        //*smallestAngle = angle_down;
        NSString *msg =
        [self generateJSON:@{@"good_lift":@(1)
                             ,@"dd":@(dispDown.displ)
                             ,@"du":@(dispUp.displ)
                             ,@"dt":@((dispUp.t-dispDown.t)/(float)SAMPLE_RATE)
                             //,@"tu":@(dispUp.t)
                             ,@"ad":@(*smallestAngle)
                             ,@"au":@(angle_up)
                             }];
        NSLog (@"%@",msg); if (_isConnected) { [self write2server:msg]; }
        return YES;
    } // if (ALL_MATCHING)
    return NO;
} // checkGoodLift

#pragma mark Button Callbacks

//-------------------
- (void) cbConnect
//-------------------
{
    [self disconnectServer];

    if ([_txtIPA.text length] == 0
        || [_txtIPB.text length] == 0
        || [_txtIPC.text length] == 0
        || [_txtIPD.text length] == 0)
    {
        [self popup:@"IP part missing" title:@"Error"]; return;
    }
    if ([_txtPort.text length] == 0) {
        [self popup:@"Port missing" title:@"Error"]; return;
    }
    int ipa = [_txtIPA.text intValue];
    int ipb = [_txtIPB.text intValue];
    int ipc = [_txtIPC.text intValue];
    int ipd = [_txtIPD.text intValue];
    int port = [_txtPort.text intValue];
    if (ipa > 255) { [self popup:@"illegal IP" title:@"Error"]; return; }
    if (ipb > 255) { [self popup:@"illegal IP" title:@"Error"]; return; }
    if (ipc > 255) { [self popup:@"illegal IP" title:@"Error"]; return; }
    if (ipd > 255) { [self popup:@"illegal IP" title:@"Error"]; return; }
    if (port > 0xffff) { [self popup:@"illegal Port" title:@"Error"]; return; }
    
    [self putNum:@"IPA" val:@(ipa)];
    [self putNum:@"IPB" val:@(ipb)];
    [self putNum:@"IPC" val:@(ipc)];
    [self putNum:@"IPD" val:@(ipd)];
    [self putNum:@"PORT" val:@(port)];
    
    NSString *server = nsprintf (@"%d.%d.%d.%d",ipa,ipb,ipc,ipd);
    [self connect2server:server port:port];
        //[self write2server:@"start_stream"];
    [self ledAmber];
} // cbConnect()

//----------------------------------
- (IBAction)btnConnect:(id)sender
//----------------------------------
{
    if (!_isConnected) {
        [self cbConnect];
    } else {
        //[self disconnectServer];
    }
}

//-----------------------------
- (IBAction)btnLed:(id)sender
//-----------------------------
{
    [self btnConnect:sender];
}


//------------------------------
- (IBAction)btnMenu:(id)sender
//------------------------------
{
    [g_app.naviVc pushViewController:g_app.menuVc animated:YES];
}


#pragma mark IP Address

//----------------------------------------------------------
- (BOOL)               textField:(UITextField *)textField
   shouldChangeCharactersInRange:(NSRange)range
               replacementString:(NSString *)str
//----------------------------------------------------------
// Restrict all textfield input to digits only
{
    if (!strmatch(str,@"^[0-9]*$")) { return NO; }
    int maxlen = 3;
    if (textField == _txtPort) { maxlen = 5; }
    long len = [textField.text length] + [str length] - range.length;
    return (len > maxlen) ? NO : YES;
}

//-----------------
- (void) initIP
//-----------------
// Init textfields to values stored in userdefaults
{
    _txtIPA.text = [self getStr:@"IPA"];
    _txtIPB.text = [self getStr:@"IPB"];
    _txtIPC.text = [self getStr:@"IPC"];
    _txtIPD.text = [self getStr:@"IPD"];
    _txtPort.text = [self getStr:@"PORT"];
}

#pragma  mark Server Connectivity

//-------------------------------------------------------------
- (void)connectTimeout:(NSTimer*)timer
//-------------------------------------------------------------
// Socket connection timeout
{
    [self disconnectServer];
    [self popup:@"Connect failed" title:@"Error"];
}


// Make a TCP/IP connection to a server.
// Sets the member variables mIStream and mOStream.
// Use them to communicatte with the server.
//----------------------------------------
- (BOOL)connect2server:(NSString *)server
                  port:(int)port
//----------------------------------------
{
    
    // Give up after some seconds
    _connectTimeout =
    [NSTimer scheduledTimerWithTimeInterval: 4.0
                                     target: self
                                   selector: @selector(connectTimeout:)
                                   userInfo: nil
                                    repeats: NO];
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       (__bridge CFStringRef) server,
                                       port,
                                       &mReadStream,
                                       &mWriteStream);
    
    if (mReadStream && mWriteStream) {
        CFReadStreamSetProperty (mReadStream,
                                kCFStreamPropertyShouldCloseNativeSocket,
                                kCFBooleanTrue);
        CFWriteStreamSetProperty (mWriteStream,
                                 kCFStreamPropertyShouldCloseNativeSocket,
                                 kCFBooleanTrue);
        
        mIStream = (__bridge NSInputStream *)mReadStream;
        //[mIStream retain];
        [mIStream setDelegate:self];
        [mIStream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                            forMode:NSDefaultRunLoopMode];
        [mIStream open];
        
        mOStream = (__bridge NSOutputStream *)mWriteStream;
        //[mOStream retain];
        [mOStream setDelegate:self];
        [mOStream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                            forMode:NSDefaultRunLoopMode];
        [mOStream open];
        
        return YES;
    }
    return NO;
} // connect2server()

//--------------------------
- (void) ledGreen
//--------------------------
{
    UIImage *greenLED = [UIImage imageNamed:@"green-led-on-md.png"];
    [_btnLED setImage:greenLED forState:UIControlStateNormal];
    _isConnected = YES;
}

//--------------------------
- (void) ledRed
//--------------------------
{
    UIImage *redLED = [UIImage imageNamed:@"led-red-control-md.png"];
    [_btnLED setImage:redLED forState:UIControlStateNormal];
    _isConnected = NO;
}

//--------------------------
- (void) ledAmber
//--------------------------
{
    UIImage *amberLED = [UIImage imageNamed:@"amber-led-on-md.png"];
    [_btnLED setImage:amberLED forState:UIControlStateNormal];
    _isConnected = NO;
}

// Disconnect from server
//--------------------------
- (void)disconnectServer
//--------------------------
{
    if (mIStream != nil) [mIStream close];
    if (mOStream != nil) [mOStream close];
    mIStream = nil;
    mOStream = nil;
    [self ledRed];
} // disconnectServer()

// Write a null terminated string to the server
//-------------------------------------------
- (void) write2server:(NSString *)p_msg
//-------------------------------------------
{
    const char *msg = [p_msg cStringUsingEncoding:NSUTF8StringEncoding];
    [mOStream write:(uint8_t *)msg maxLength:strlen(msg)];
} // write2server()

// Stream events and data from the server
//------------------------------------------------------------------------
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
//------------------------------------------------------------------------
{
    if (_connectTimeout) {
        [_connectTimeout invalidate];
        _connectTimeout = nil;
    }
    NSMutableData *data = [NSMutableData new];
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable: {
            uint8_t buf[1024];
            unsigned long len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {
                [data appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            NSString *str =
            [[NSString alloc] initWithData:data
                                  encoding:NSUTF8StringEncoding];
//            if ([str length]) {
//                [self popup:str title:@"Server Message"];
//            }
            [self handlePhoneMsg:str];
            break;
        }
        case NSStreamEventErrorOccurred: {
            [self disconnectServer];
            NSError *theError = [stream streamError];
            NSString *msg = nsprintf (@"Error %d: %@"
                                      ,[theError code]
                                      ,[theError localizedDescription]);
            [self popup:msg title: @"Stream Error"];
            break;
        }
        case NSStreamEventNone: {
            NSLog (@"NSStreamEventNone");
            break;
        }
        case NSStreamEventOpenCompleted: {
            [self ledGreen];
            NSLog (@"NSStreamEventOpenCompleted");
            break;
        }
        case NSStreamEventHasSpaceAvailable: {
            //NSLog (@"NSStreamEventHasSpaceAvailable");
            break;
        }
        case NSStreamEventEndEncountered: {
            NSLog (@"NSStreamEventEndEncountered");
            break;
        }
        default: {
            [self popup:@"unknown stream event" title: @"Stream Error"];
        }
    } // switch
} // handleEvent

//----------------------------------------
- (void) handlePhoneMsg:(NSString *)msg
//----------------------------------------
// Parse and handle commands from phone to sensor
{
    NSLog (@"phone msg: %@",msg);
    if (strmatch (msg,@"^cal$")) {
        [self reorient];
    } else {
        NSLog (@"ERROR: unknown phone msg: %@",msg);
    }
} // handlePhoneMsg

//------------------
- (void) initRot
//------------------
// Fill rot matrix with plausible default
{
    _rot.m[0][0] = 0;  _rot.m[0][1] = 0;    _rot.m[0][2] = -1;
    _rot.m[1][0] = -1; _rot.m[1][1] = 0;    _rot.m[1][2] = 0;
    _rot.m[2][0] = 0;  _rot.m[2][1] = 1;    _rot.m[2][2] = 0;
} // initRot

//-------------------------------
-(void)tmCalib:(NSTimer *)timer
//-------------------------------
// When timer fires, reorient.
// This happens if little motion (g_bp) for CALIBTIMEOUT secs.
{
    [self reorient];
    //_qDisplacement = [NSMutableArray new];
    //angle (LP_INIT,0,0,0,NULL);
    [self restartTmCalib];
} // tmCalib

//-------------------------------
-(void)restartTmCalib
//-------------------------------
// When timer fires, reorient
{
    [_tmCalib invalidate];
    _tmCalib =
    [NSTimer scheduledTimerWithTimeInterval:CALIBTIMEOUT
                                     target:self
                                   selector:@selector(tmCalib:)
                                   userInfo:nil
                                    repeats:YES];
} // restartTmCalib

//------------------
- (void) reorient
//------------------
// Compute rot matrix transforming current gravity vector to (0,1,0)
{
    LP_matrix rot_y;
    
    _need_calib = NO;
    
    // Rotate up
    _rot = [self rotUp];
    float yangle = -M_PI / 2.0;
    if (_gravity.x < 0) {
        yangle *= -1;
    }
    
    // Rotate around y axis
    rot_y.m[0][0] = cos(yangle);  rot_y.m[0][1] = 0;    rot_y.m[0][2] = sin(yangle);
    rot_y.m[1][0] = 0;            rot_y.m[1][1] = 1;    rot_y.m[1][2] = 0;
    rot_y.m[2][0] = -sin(yangle); rot_y.m[2][1] = 0;    rot_y.m[2][2] = cos(yangle);
    
    matmul (&rot_y, &_rot, &_rot);
    
    _t_cutoff = g_count;
    if ([g_app.options[@"calib_sound_flag"] isEqualToString:@"ON"]) {
        [self playSystemSound:@"photoShutter"];
    }
} // reorient

//-------------------
- (LP_matrix) rotUp
//-------------------
{
    LP_matrix res;
    LP_matrix zrot;
    LP_matrix xrot;
    float x = _gravity.x;
    float y = _gravity.y;
    float z = _gravity.z;
    
    if (ABS(x) < 0.001) { x = 0.001; }
    if (ABS(y) < 0.001) { y = 0.001; }
    float xyLength = sqrt(x*(float)x + y*(float)y);
    
    float zAngle = SIGN(x) * (xyLength==0?0:acos(y/xyLength));
    
    float vecLength = sqrt(x*(float)x + y*(float)y + z*(float)z);
    
    float xAngle = -SIGN(z) * acos (xyLength / vecLength);
    
    // Rotation around z axis
    zrot.m[0][0] = cos(zAngle); zrot.m[0][1] =-sin(zAngle); zrot.m[0][2] = 0;
    zrot.m[1][0] = sin(zAngle); zrot.m[1][1] = cos(zAngle); zrot.m[1][2] = 0;
    zrot.m[2][0] = 0;           zrot.m[2][1] = 0;           zrot.m[2][2] = 1;
    
//    xAngle = 0; // No rotation around x
    // Rotation around x axis
    xrot.m[0][0] = 1; xrot.m[0][1] = 0;           xrot.m[0][2] = 0;
    xrot.m[1][0] = 0; xrot.m[1][1] = cos(xAngle); xrot.m[1][2] = -sin(xAngle);
    xrot.m[2][0] = 0; xrot.m[2][1] = sin(xAngle); xrot.m[2][2] = cos(xAngle);
    
    matmul (&xrot,&zrot,&res);
    return res;
} // rotUp

//---------------------------
- (void) normalizeGravity
//---------------------------
// Apply rotation to normalize sensor postition on body
{
    // Check for a corrupt rotation
    if (!isfinite (_rot.m[0][0] + _rot.m[0][1] + _rot.m[0][2])) {
        NSLog(@"bad rot matrix");
        //[self resetRot];
    }
    uint8_t row;
    float v[3];
    float res[3];
    v[0] = _gravity.x; v[1] = _gravity.y; v[2] = _gravity.z;
    for (row=0;row<3;row++) {
        res[row] =
        v[0] * _rot.m[row][0]
        + v[1] * _rot.m[row][1]
        + v[2] * _rot.m[row][2];
    }
    _gravityNormalized.x = res[0];
    _gravityNormalized.y = res[1];
    _gravityNormalized.z = res[2];
} // normalizeGravity

//-----------------------
- (void) updateFilters
//-----------------------
// Populate property _g_bp as on sensor
{
    static float m_old_bp_2_5 = 0;
    float veclen =
    sqrt (_userAcc.x *_userAcc.x
    + _userAcc.y * _userAcc.y
    + _userAcc.z * _userAcc.z) * 2048.0 ;
    
    // Frequency between 2 and 5 Hertz (walking/running)
    float bp_2_5 = lp_bworth_bandpass_2_5 (veclen);
    float d = bp_2_5 - m_old_bp_2_5;
    m_old_bp_2_5 = bp_2_5;
    g_bp = lp_bworth_lowpass_05 (log(1+d*d));
} // updateFilters

#pragma mark UI Helpers

//-------------------------------
- (void) popup:(NSString *)msg
         title:(NSString *)title
//-------------------------------
{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:title
                               message:msg
                              delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alert show];
}

//---------------------------------------------
- (void) playSystemSound:(NSString *)soundName
//---------------------------------------------
// Play an iOS system sound.
// List can be found at
// https://github.com/TUNER88/iOSSystemSoundsLibrary
{
    NSString *fullPath =
    nsprintf (@"/System/Library/Audio/UISounds/%@.caf",soundName);
    NSURL *fileURL = [NSURL URLWithString:fullPath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark Userdefaults

#define DEF [NSUserDefaults standardUserDefaults]

//-----------------------------------------------------
- (void) putNum:(NSString *)key val:(NSNumber *)val
//-----------------------------------------------------
// Store a number in UserDefaults
{
    [DEF setObject:val forKey:key];
}

//-----------------------------------------------------
- (NSNumber *) getNum:(NSString *)key
//-----------------------------------------------------
// Get number from UserDefaults
{
    return [DEF objectForKey:key];
}

//-----------------------------------------------------
- (int) getInt:(NSString *)key
//-----------------------------------------------------
// Get number from UserDefaults, return as int
{
    return [[DEF objectForKey:key] intValue];
}

//-----------------------------------------------------
- (NSString *) getStr:(NSString *)key
//-----------------------------------------------------
// Get object from UserDefaults, return as string
{
    id obj = [DEF objectForKey:key];
    return obj ? nsprintf (@"%@", [DEF objectForKey:key]) : @"" ;
}

#pragma mark Json 

//-----------------------------------------
- (NSString*) generateJSON:(id)theObject
//-----------------------------------------
// Convert any NSObject to a JSON representation
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theObject
                                                       options:0 error:&error];
    if (!jsonData) {
        NSLog (@"failed to convert object to json: %@",theObject);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return nsprintf (@"%@\n",jsonString);
} // generateJSON

//-----------------------------------------
- (id) parseJSON:(NSString*)theJSON
//-----------------------------------------
// Parse Json into an NSObject
{
    NSData *theData = [theJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *theError = nil;
    id objFromJson = [NSJSONSerialization JSONObjectWithData:theData
                                                     options:0
                                                       error:&theError];
    if (!objFromJson)
    {
        NSLog (@"failed parse json: %@",theJSON);
        return nil;
    }
    return objFromJson;
} // parseJSON


#pragma Cruft

//--------------------------------------------------------
- (BOOL) textFieldShouldReturn:(UITextField *)textField
//--------------------------------------------------------
// Hide keyboards on return
{
    [textField resignFirstResponder];
    return YES;
}

#pragma  mark C Funcs

//-------------------------------------
CMQuaternion rot2quat (LP_matrix *p_m)
//-------------------------------------
// Make a quaternion from a rot matrix.
// This is a little messy for numeric stability.
// (by Martin Baker on euklideanspace.com)
{
    float (*m)[3];
    m = p_m->m; //  m[1][2] == p_m->m[1][2]
    CMQuaternion res;
    
    float tr = m[0][0] + m[1][1] + m[2][2];
    
    if (tr > 0) {
        float S = sqrt(tr+1.0) * 2; // S=4*qw
        res.w = 0.25 * S;
        res.x = (m[2][1] - m[1][2]) / S;
        res.y = (m[0][2] - m[2][0]) / S;
        res.z = (m[1][0] - m[0][1]) / S;
    } else if ((m[0][0] > m[1][1])&(m[0][0] > m[2][2])) {
        float S = sqrt(1.0 + m[0][0] - m[1][1] - m[2][2]) * 2; // S=4*qx
        res.w = (m[2][1] - m[1][2]) / S;
        res.x = 0.25 * S;
        res.y = (m[0][1] + m[1][0]) / S;
        res.z = (m[0][2] + m[2][0]) / S;
    } else if (m[1][1] > m[2][2]) {
        float S = sqrt(1.0 + m[1][1] - m[0][0] - m[2][2]) * 2; // S=4*qy
        res.w = (m[0][2] - m[2][0]) / S;
        res.x = (m[0][1] + m[1][0]) / S;
        res.y = 0.25 * S;
        res.z = (m[1][2] + m[2][1]) / S;
    } else {
        float S = sqrt(1.0 + m[2][2] - m[0][0] - m[1][1]) * 2; // S=4*qz
        res.w = (m[1][0] - m[0][1]) / S;
        res.x = (m[0][2] + m[2][0]) / S;
        res.y = (m[1][2] + m[2][1]) / S;
        res.z = 0.25 * S;
    }
    return res;
} // rot2quat
@end // MainVC

