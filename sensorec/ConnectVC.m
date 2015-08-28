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

#import <GLKit/GLKit.h>

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

// BLE connection state changed
//----------------------------------------------------------
- (void) peripheral: (nonnull LBPeripheral *) peripheral
     didUpdateState: (CBPeripheralState) state
{
    [self.tableView reloadData];
    if (state == CBPeripheralStateConnected) {
        // We clicked on the sensor on the tbview and then
        // made a BLE link and did the base fw init sequence.
        // All base fw properties have been set.
        self.peripheral = peripheral;
        // Reset whatever the app knows about the XRM
        g_app.xrmPlatform = nil;
    }
}

// A JSON message or and SDB message came from the XRM
//---------------------------------------------------------
- (void) peripheral: (nonnull LBPeripheral *) peripheral
  didReceiveCommand: (nonnull LBCommand *) command
{
    static int msgNum = 0;
    msgNum++;
    NSLog(@"Command: %@", command);
    
    if([command isKindOfClass:[LBSDBCommand class]]) {
        LBSDBCommand* sdbCommand = (LBSDBCommand*)command;
        NSData* sdb = sdbCommand.selfDescriptiveBinary;
        NSDictionary *kv = [self parseSDB:sdb];
        NSArray *keys = kv[@"orderedkeys"];
        // Don't log quaternion
        if ([keys isEqualToArray:@[@"w",@"x",@"y",@"z"]]) {}
        else { [g_app.consoleVc prdict:kv num:msgNum]; }
        [self handleSDB:kv];
    }
    else if([command isKindOfClass:[LBJSONCommand class]]) {
        LBJSONCommand* jsonCommand = (LBJSONCommand*)command;
        NSDictionary* json =
        [NSJSONSerialization
         JSONObjectWithData:[jsonCommand.jsonString dataUsingEncoding:NSUTF8StringEncoding]
         options:0 error:nil];
        [g_app.consoleVc pr:jsonCommand.jsonString num:msgNum];
        [self handleJSON:json];
    }
}

#pragma mark - Process JSON Messages
//----------------------------------------
- (void)handleJSON:(NSDictionary *) json
{
    if ([json[@"type"] isEqualToString:@"PLATFORM"]) {
        g_app.xrmPlatform = json[@"str"];
        //[g_app.naviVc pushViewController:g_app.mainVc animated:YES];
    }
} // handleJSON()

#pragma mark - Process Self Descriptive Binary Messages

// Act on an SBD message from the plugin
//---------------------------------------
- (void)handleSDB:(NSDictionary *)kv
{
    NSArray *keys = kv[@"orderedkeys"];
    if ([keys isEqualToArray:@[@"w",@"x",@"y",@"z"]]) {
        GLKQuaternion glkq;
        glkq.q[0] = [kv[@"x"] intValue] / (float) (1L<<14);
        glkq.q[1] = [kv[@"y"] intValue] / (float) (1L<<14);
        glkq.q[2] = [kv[@"z"] intValue] / (float) (1L<<14);
        glkq.q[3] = [kv[@"w"] intValue] / (float) (1L<<14); 
        
        NSLog(@"wxyzl %.4f %.4f %.4f %.4f", glkq.q[0], glkq.q[1], glkq.q[2], glkq.q[3]);
        [g_app.brickVc animateQuaternion: glkq];
    } else {
        NSLog(@"%@",kv);
    }
} // deviceSDB()

// Parse a self descriptive binary message from the plugin
//---------------------------------------------------------
- (NSDictionary *) parseSDB:(NSData *)data
{
    unsigned char *bytes = (unsigned char *)[data bytes];
    if (bytes[0] == '@') { // binary key/value message
        NSMutableDictionary *res = [NSMutableDictionary new];
        NSMutableArray *keys = [NSMutableArray new];
        int16_t val16;
        int32_t val32;
        for (unsigned char *p=bytes+1; *p; p++) {
            unsigned char c = *p;
            NSString *key = nsprintf(@"%c",c);
            [keys addObject:key];
            if (c >= 'a' && c <= 'z') { // lower case, 16 bit
                ((char *)&val16)[0] = *++p;
                ((char *)&val16)[1] = *++p;
                res[key] = @(val16);
            }
            else { // upper case, 32 bit
                ((char *)&val32)[0] = *++p;
                ((char *)&val32)[1] = *++p;
                ((char *)&val32)[2] = *++p;
                ((char *)&val32)[3] = *++p;
                res[key] = @(val32);
            }
        } // for
        res[@"orderedkeys"] = keys;
        return res;
    }
    else { // string msg
        NSLog (@"parseSDB(): Not an SDB message");
        return nil;
    }
    return nil;
} // parseSDB()



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
