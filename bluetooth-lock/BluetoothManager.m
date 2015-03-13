//
//  BluetoothManager.m
//  bluetooth-lock
//
//  Created by Sumit on 26/01/15.
//  Copyright (c) 2015 sumit. All rights reserved.
//

#import "BluetoothManager.h"

#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180D"
#define POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID @"2A29"

@interface BluetoothManager (){
    BOOL deviceConnected;
}

@end

@implementation BluetoothManager
@synthesize centralObject;

- (id) init{
    self = [super init];
    if(self){
        self.peripherals=[NSMutableArray new];
    }
    return self;
}


- (void) discoverDevices{
    self.centralObject = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

//
//+ (BluetoothManager *)sharedInstance{
//    static BluetoothManager *_sharedInstance = nil;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _sharedInstance = [[BluetoothManager alloc] init];
//        _sharedInstance.peripherals = [NSMutableArray new];
//    });
//    return _sharedInstance;
//}

- (void) startScan
{
    NSLog(@"Start scanning");
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.centralObject scanForPeripheralsWithServices:nil options:options];
    
}


- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([self.centralObject state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            [self startScan];
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    return FALSE;
}


#pragma mark - CBPeripheralDelegate
// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"here");
}

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"here");
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
        NSLog(@"here");
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
        NSLog(@"here");
}

#pragma mark - CBCentralManagerDelegate
// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    deviceConnected = YES;
    [peripheral readRSSI];
    [peripheral setDelegate:self];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    deviceConnected = NO;
    [self discoverDevices];
    [self performSelector:@selector(lockDevice) withObject:nil afterDelay:4.0];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
        NSLog(@"here");
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self calculateDistanceFromPeripheral:peripheral];
    [LockManager unlockScreen];
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{

        NSLog(@"Discovered peripheral %@",peripheral.identifier.UUIDString);
        [self.peripherals addObject:peripheral];
        [central connectPeripheral:peripheral options:nil];
        [central setDelegate:self];
        [self.centralObject stopScan];


}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self isLECapableHardware];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

- (void) lockDevice{
    if(!deviceConnected){
        NSLog(@"disconnected");
        [LockManager lockScreen];
    }
}

- (void) calculateDistanceFromPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"peripheral rssi %ld",(long)peripheral.RSSI.integerValue);
    if(peripheral.RSSI.integerValue > -100){
        deviceConnected = YES;
    }
    else{
        deviceConnected = NO;
    }
//    switch (peripheral.RSSI.integerValue) {
//        case -40:
//            //1m
//            break;
//        case -46:
//            //2m
//            break;
//        case -52:
//            //4m
//            break;
//        case -58:
//            //8m
//            break;
//        case -64:
//            //16
//            break;
//        default:
//            break;
//    }
//    NSLog(@"rssi value %ld",(long)peripheral.RSSI.integerValue);
}

@end
