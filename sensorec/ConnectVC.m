//
//  ConnectVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-27.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "ConnectVC.h"
#import "MainVC.h"
#import "common.h"
#import "Utils.h"
#import "BluetoothMasterCell.h"

@interface ConnectVC () <LBCentralManagerDelegate, LBPeripheralDelegate>
@property (strong, nonatomic) LBCentralManager* centralManager;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation ConnectVC

- (nonnull instancetype)init {
    self = [super init];
    if(self) {
        self.centralManager = [[LBCentralManager alloc] initWithDelegate:self lumoServices:@[LBServiceLumoFlightUUID]];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.centralManager stopScanning];
}

#pragma mark - IBActions

- (IBAction)scanButtonPressed:(nonnull UIBarButtonItem*)sender {
    if([sender.title isEqualToString:@"Scan"]) {
        sender.title = @"Stop";
        [self.centralManager scanForLumoProducts];
    } else {
        sender.title = @"Scan";
        [self.centralManager stopScanning];
    }
    [self.tableView reloadData];
}

- (IBAction)closeButtonPressed:(id)sender {
    if(self.peripheral) {
        switch(self.peripheral.state) {
            case CBPeripheralStateConnected:
            {
                self.connected = YES;
                self.mySensoName = self.peripheral.identifier.UUIDString;
                [self.centralManager stopScanning];
                if ([g_app.naviVc topViewController] == g_app.connectVc) {
                    [g_app.naviVc popViewControllerAnimated:YES];
                }
                break;
            }
            default:
            {
                self.connected = NO;
                if ([g_app.naviVc.viewControllers count] == 1) {
                    [g_app.naviVc pushViewController:g_app.connectVc animated:YES];
                }
                [self.centralManager scanForLumoProducts];
                break;
            }
        }
    }
}

#pragma mark - LBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManagerState)state {
    switch(state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"Bluetooth state is unknown.");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"Bluetooth is currently resetting.");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth is currently powered off.");
            break;
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"Bluetooth is currently powered on.");
            break;
        }
        default:
            NSLog(@"Bluetooth state has an unexpected value.");
    }
    
    [self.centralManager stopScanning];
    [self.tableView reloadData];
}

- (void)centralManagerDidDiscoverPeripheral:(nonnull LBPeripheral*)peripheral advertisementData:(nonnull NSDictionary<NSString *,id>*)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    // NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSString* localName = advertisementData[CBAdvertisementDataLocalNameKey];
    if([localName hasSuffix:@"*"]) {
        [self.centralManager rememberPeripheral:peripheral];
    }
    
    [self.tableView reloadData];
}

- (void)centralManagerDidConnectPeripheral:(nonnull LBPeripheral*)peripheral {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    peripheral.delegate = self;
    [self.tableView reloadData];
}

- (void)centralManagerDidDisconnectPeripheral:(nonnull LBPeripheral*)peripheral {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    peripheral.delegate = nil;
    [self.tableView reloadData];
}

- (void)centralManagerDidFailToConnectPeripheral:(nonnull LBPeripheral *)peripheral {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.tableView reloadData];
}

#pragma mark - LBPeripheralDelegate

- (void)peripheral:(nonnull LBPeripheral *)peripheral didUpdateState:(CBPeripheralState)state {
    [self.tableView reloadData];
    if(state == CBPeripheralStateConnected) {
        self.peripheral = peripheral;
    }
}

- (void)peripheral:(nonnull LBPeripheral *)peripheral didReceiveCommand:(nonnull LBCommand *)command {
    NSLog(@"Command: %@", command);
    
    if([command isKindOfClass:[LBSDBCommand class]]) {
        LBSDBCommand* sdbCommand = (LBSDBCommand*)command;
        NSData* sdb = sdbCommand.selfDescriptiveBinary;
        // Process data
        [self onUserMsgReceived:(Byte*)sdb.bytes len:sdb.length];
    } else if([command isKindOfClass:[LBJSONCommand class]]) {
        LBJSONCommand* jsonCommand = (LBJSONCommand*)command;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[jsonCommand.jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        if([json[@"type"] isEqualToString:@"PLATFORM"]) {
            [self handleStrMsg:json[@"str"]];
        }
    }
}

#pragma mark - Process Self Descriptive Binary Messages

//-------------------------------------------------------
- (void) onUserMsgReceived:(Byte*)bytes
                       len:(unsigned long)length
//-------------------------------------------------------
// Application (aka PRM) message from sensor.
// Called from SensoPlex.m
{
    static int msgNum = 0;
    static NSArray *currentBlurp;
    msgNum++;
    //    SensoPlex *senso = g_app.connectVc.sensoPlex;
    if (bytes[1] == '@') { // binary key/value message
        NSMutableArray *keys = [NSMutableArray new];
        NSMutableArray *values = [NSMutableArray new];
        int16_t val16;
        int32_t val32;
        long val;
        for (unsigned char *p=bytes+2; *p; p++) {
            if (*p == '@') { continue; }
            unsigned char c = *p;
            if (c >= 'a' && c <= 'z') { // lower case, 16 bit
                ((char *)&val16)[0] = *++p;
                ((char *)&val16)[1] = *++p;
                [keys addObject:nsprintf(@"%c",c)];
                val = val16; // for 64-bit phones
                [values addObject:nsprintf(@"%ld",val)];
            }
            else { // upper case, 32 bit
                ((char *)&val32)[0] = *++p;
                ((char *)&val32)[1] = *++p;
                ((char *)&val32)[2] = *++p;
                ((char *)&val32)[3] = *++p;
                [keys addObject:nsprintf(@"%c",c)];
                val = val32; // for 64-bit phones
                [values addObject:nsprintf(@"%ld",val)];
            }
        } // for
        
        // Hardware Sensor Fusion  Quaternion
        if ([keys isEqualToArray:@[@"w",@"x",@"y",@"z"]]) {
            [g_app.brickVc fusionFU];
            [g_app.brickVc animateQuaternion:values];
        }
        // Software Open Source Quaternion
        else if ([keys isEqualToArray:@[@"v",@"x",@"y",@"z"]]) {
            [g_app.brickVc fusionOS];
            [g_app.brickVc animateQuaternion:values];
        }
        // Cadence, Bounce, Lurch, Plod
        else if ([keys isEqualToArray:@[@"c",@"b",@"l",@"p"]]) {
            [g_app.consoleVc pr:keys values:values num:msgNum];
            // Remember blurp values until rotations come in
            currentBlurp = values;
        }
        // Rotation around x,y,z
        else if ([keys isEqualToArray:@[@"r",@"y",@"z"]]) {
            [g_app.consoleVc pr:keys values:values num:msgNum];
            [g_app.blurpVc cadence:currentBlurp[0]
                            bounce:currentBlurp[1]
                             lurch:currentBlurp[2]
                              plod:currentBlurp[3]
                              rotx:values[0]
                              roty:values[1]
                              rotz:values[2]];
        }
        else {
            [g_app.consoleVc pr:keys values:values num:msgNum];
        }
    }
    else { // string msg
        //msgNum++;
        NSString *str = nsprintf(@"%s",bytes+1);
        [g_app.consoleVc pr:str num:msgNum];
        [self handleStrMsg:str];
    }
    //[g_app.consoleVc pr:nsprintf (@"%ld ",msgNum) color:RGB(0x0f7002)];
} // onUserMsgReceived

//-----------------------------------------
- (void) handleStrMsg: (NSString *)msg
//-----------------------------------------
// A string message from the sensor came in. Deal with it.
{
    if ([msg isEqualToString:@"lifting"]) {
        g_app.sensoApp = @"sensolifting";
        g_app.gotSensoApp = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Lifting" forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = NO;
            g_app.mainVc.lbRecords.hidden = YES;
            g_app.mainVc.lbBytes.hidden = YES;
            g_app.mainVc.lbTotal.hidden = YES;
            g_app.mainVc.btnLed.hidden = NO;
            g_app.mainVc.lbRecordsUsed.hidden = YES;
            g_app.mainVc.lbBytesUsed.hidden = YES;
            g_app.mainVc.lbTotlab.hidden = YES;
            g_app.mainVc.btnClear.hidden = YES;
            g_app.mainVc.btnShutter.hidden = NO;
            g_app.mainVc.btnAnimation.hidden = YES;
            g_app.mainVc.btnBlurp.hidden = YES;
        });
    }
    else if ([msg isEqualToString:@"run"]) {
        g_app.sensoApp = @"sensorun";
        g_app.gotSensoApp = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Start Recording" forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = YES;
            g_app.mainVc.lbRecords.hidden = NO;
            g_app.mainVc.lbBytes.hidden = NO;
            g_app.mainVc.lbTotal.hidden = NO;
            g_app.mainVc.btnLed.hidden = NO;
            g_app.mainVc.lbRecordsUsed.hidden = NO;
            g_app.mainVc.lbBytesUsed.hidden = NO;
            g_app.mainVc.lbTotlab.hidden = NO;
            g_app.mainVc.btnClear.hidden = NO;
            g_app.mainVc.btnShutter.hidden = YES;
            g_app.mainVc.btnAnimation.hidden = YES;
            g_app.mainVc.btnBlurp.hidden = YES;
        });
    }
    else if ([msg isEqualToString:@"dev"]) {
        g_app.sensoApp = @"sensodev";
        g_app.gotSensoApp = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [g_app.mainVc.btnRecord setTitle:@"Start Recording" forState:UIControlStateNormal];
            g_app.mainVc.btnRecord.enabled = YES;
            g_app.mainVc.lbRecords.hidden = NO;
            g_app.mainVc.lbBytes.hidden = NO;
            g_app.mainVc.lbTotal.hidden = NO;
            g_app.mainVc.btnLed.hidden = NO;
            g_app.mainVc.lbRecordsUsed.hidden = NO;
            g_app.mainVc.lbBytesUsed.hidden = NO;
            g_app.mainVc.lbTotlab.hidden = NO;
            g_app.mainVc.btnClear.hidden = NO;
            g_app.mainVc.btnShutter.hidden = YES;
            g_app.mainVc.btnAnimation.hidden = NO;
            g_app.mainVc.btnBlurp.hidden = NO;
        });
    }
    else if ([msg hasPrefix:@"gl:"]) {
        int minangle = [[msg componentsSeparatedByString:@":"][1] intValue];
        //if (minangle > 50) {
        if (minangle > 45) {
            [self playGoodSound];
        } else {
            [self playStraightSound];
        }
    }
    else if ([msg hasPrefix:@"bl:"]) {
        [self playBadSound];
    }
    else if ([msg hasPrefix:@"calib"]) {
        NSString *opt = g_app.options[@"calib_sound_flag"];
        if ([opt isEqualToString:@"ON"]) {
            [self playCalibSound];
        }
    }
} // handleStrMsg

//--------------------------
- (void) playBadSound
//--------------------------
{
    [self playSystemSound:@"low_power"];
}
//--------------------------
- (void) playGoodSound
//--------------------------
{
    [self playSystemSound:@"SIMToolkitPositiveACK"];
}
//--------------------------
- (void) playCalibSound
//--------------------------
{
    [self playSystemSound:@"photoShutter"];
}
//--------------------------
- (void) playStraightSound
//--------------------------
{
    AudioServicesPlaySystemSound (g_app.backStraightSound);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [self.centralManager rememberedPeripherals].count : [self.centralManager discoveredLumoPeripherals].count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LBPeripheral* peripheral = indexPath.section == 0 ? [self.centralManager rememberedPeripherals][indexPath.row] : [self.centralManager discoveredLumoPeripherals][indexPath.row];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDiscoveredPeripheralCellIdentifier forIndexPath:indexPath];
    NSString *cellId = @"cellID";
    BluetoothMasterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell == nil)
    {
        cell = [[BluetoothMasterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    cell.textLabel.text = [peripheral identifier].UUIDString;
    cell.detailTextLabel.text = @"";
    
    if(peripheral.state == CBPeripheralStateConnected) {
        // cell.textLabel.text = [NSString stringWithFormat:@"\u2713 %@", cell.textLabel.text];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSMutableString* detailText = [[NSMutableString alloc] initWithString:@""];
        if(peripheral.platform) {
            [detailText appendString:(peripheral.platform.processor == LBPlatformProcessorEFM32) ? @"EFM32 " : @"NRF51 "];
        }
        
        if(peripheral.baseFirmwareMetadata) {
            [detailText appendFormat:@"Base: %d ", peripheral.baseFirmwareMetadata.revision];
        }
        
        if(peripheral.pluginFirmwareMetadata) {
            [detailText appendFormat:@"Plugin: %d ", peripheral.pluginFirmwareMetadata.revision];
        }
        
        if(peripheral.batteryState) {
            [detailText appendFormat:@"Battery: %.1f%%", [peripheral.batteryState batteryChargePercent]];
        }
        
        cell.detailTextLabel.text = detailText;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        // Clicking here has other uses not yet determined
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        // Discovered Peripherals section - let's connect
        LBPeripheral* peripheral = [self.centralManager discoveredLumoPeripherals][indexPath.row];
        if(peripheral.state == CBPeripheralStateDisconnected || peripheral.state == CBPeripheralStateDisconnecting) {
            [self.centralManager rememberPeripheral:peripheral];
            self.peripheral = peripheral;
            [self.tableView reloadData];
        }
    }
}

- (BOOL)tableView:(nonnull UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? YES : NO;
}

- (nullable NSString*)tableView:(nonnull UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return @"Forget";
}

- (void)tableView:(nonnull UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LBPeripheral* peripheral = [self.centralManager rememberedPeripherals][indexPath.row];
        [self.centralManager forgetPeripheral:peripheral];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(nonnull UITableView *)tableView canMoveRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return NO;
}

- (nullable NSString*)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Remembered Peripherals" : @"Discovered Peripherals";
}

//==============================
#pragma mark UI Helpers
//==============================

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


@end
