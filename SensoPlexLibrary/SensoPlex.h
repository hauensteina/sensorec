//
//  SensoPlex.h
// 
//
//  Created by Jeremy Millers on 7/31/13.
//  Copyright (c) 2013 SweetSpotScience. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.

//  You should have received a copy of the GNU Lesser General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class SensorData;
@class SensorLogData;
@class SensorDataConfig;
@class SensorDataLogStatus;
@class SensorDataLogStreamConfig;


// Delegate Protocol for callbacks as things happen
@protocol SensoPlexDelegate <NSObject>

@optional

// optional callback when the connection state changes.
// use the SensoPlex.state property to determine the current state
-(void) onSensoPlexConnectStateChange;

// optional callback that can be implemented to control which SensoPlex
// peripheral to connect to (this only gets called on peripherals that
// have been recognized as SensoPlex peripherals, not on all BLE peripherals)
-(BOOL) shouldConnectToSensoPlexPeripheral:(CBPeripheral*)peripheral;

// optional callback that notifies the delegate of found sensoplex peripheral
-(void) didDiscoverSensoplexPeripheral:(CBPeripheral*)peripheral
                                  name:(NSString *)name;

// optional callback that gets called when the firmware version has
// been retrieved.
// use the SensoPlex.firmwareVersion property to get the firmware version
-(void) onFirmwareVersionRetrieved;

// optional callback when we retrieve battery status information
// use the SensoPlex.batteryVolts and SensoPlex.isBatteryCharging to
// get the current battery information
-(void) onBatteryStatusRetrieved;

// optional callback when we retrieve log data status
- (void) onSensorLogStatusParsed:(SensorDataLogStatus*)data;

// optional callback when we retrieve stream config data
- (void) onSensorStreamConfigDataParsed:(SensorDataLogStreamConfig*)data;

// optional callback when we retrieve stream config data (3 types)
- (void) onSensorLogConfigDataParsed:(NSArray*)data;

// optional callback when we retrieve log record
- (void) onSensorLogRecordParsed:(SensorLogData*)data;

// optional callback when we retrieved all log data
- (void) onSensorLogRecordComplete;

@end

// SensoPlexSensorDataDelegate can be used to get a callback every time sensor
// data is retrieved and parsed.
@protocol SensoPlexSensorDataDelegate <NSObject>

// callback when we have retrieved and parsed sensor data
- (void) onSensorData:(SensorData*) sensorData;

@end

// SensoPlexState enum - the different connection states that we recognize
typedef enum {
    SensoPlexDisconnected = 0,
    SensoPlexScanning,
    SensoPlexConnecting,
    SensoPlexConnected,
    SensoPlexReady,
    SensoPlexFailedToConnect,
    SensoPlexBluetoothError
} SensoPlexState;

// SensoPlexLEDState - the different states of the LED that we recognize
typedef enum {
    LEDSystemControl = 0,
    LEDGreen = 1 << 0,
    LEDRed = 1 << 1
} SensoPlexLEDState;

typedef enum {
    SensoPlexBLEConnectionModeDiscoveryOnly = 0,
    SensoPlexBLEConnectionModeAutoConnection,
} SensoPlexBLEConnectionMode;

// SensoPlex
@interface SensoPlex : NSObject

// our delegate(s)
@property (weak, nonatomic) NSObject<SensoPlexDelegate> *delegate;
@property (weak, nonatomic) NSObject<SensoPlexSensorDataDelegate> *sensorDataDelegate;

// current state
@property (assign) SensoPlexState state;

// connection mode
@property (assign) SensoPlexBLEConnectionMode bleConnectionMode;

// whether we are currently capturing streaming data or not
@property (assign) BOOL isCapturingData;

// sensor data that we have captured and parsed
// (SensorData*) objects in the array
@property (strong, nonatomic) NSMutableArray *sensorData;

// the firmware version (if it has been retrieved)
@property (strong, nonatomic) NSString *firmwareVersion;

// the current battery level (in volts) - if it has been retrieved
@property (assign) float batteryVolts;
@property (assign) BOOL isBatteryCharging;

// logging options
@property (assign) BOOL logBLEStats;
@property (assign) BOOL logBLEPackets;

// start / stop scanning for BLE peripherals to connect to
- (void) scanForBLEPeripherals;
- (void) stopScanningForBLEPeripherals;

// discover BLE peripherals (just list the devices, do not connect to any of them)
- (void) discoverBLEPeripherals;
- (void) stopDiscoveringBLEPeripherals;
- (void) disconnectConnectedPeripheral;

// retrieve the firmware version (asyncronously)
// the SensoPlexDelegate:onFirmwareVersionRetrieved callback gets made
// when the firmware version is retrieved
- (BOOL) getFirmwareVersion;

- (BOOL) getConfig;

// get the current temperature
- (BOOL) getTemperature;

// get the current pressure
- (BOOL) getPressure;

// get the current system time
- (BOOL) getSystemTime;

// get the current status of the SP-10BN Module
- (BOOL) getStatus;

// change the LED state
- (BOOL) setLED:(SensoPlexLEDState)ledState;

// start / stop capturing sensor data
- (BOOL) startCapturingData:(id)options;
- (BOOL) stopCapturingData;
// retrieve the sensor data streaming config
- (BOOL) getDataStreamingConfig;

// start / stop capturing sensor data
- (BOOL) startLoggingData;
- (BOOL) stopLoggingData;
// get current logging status
- (BOOL) getLogStatus;
// get logging config
- (BOOL) getLoggingConfig;
// log first record
- (BOOL) getLogFirstRecord;
// log record
- (BOOL) getLogRecordWithNo:(Byte)num;
// Clear sensor flash
- (BOOL) clearLoggingData;


// serialize the captured sensor data serialized in csv format to a file
// (uses default "sensor-data.csv" for the filename
// returns the full filename with path serialized to.
- (NSString *) serializeSensorData;

// serialize the captured sensor data serialized in csv format to a file
// returns the full filename with path serialized to.
- (NSString *) serializeSensorData:(NSString*)fileName;

// returns the path to where we save sensor data to
- (NSString *) getPathForSerializedData;

// delete all saved sensor data files
- (BOOL) deleteAllSerializedSensorData;

// call this when you're done with SensoPlex.
// this cancels any subscriptions (if there are any)
- (void) cleanup;

@end
