//
//  BluetoothManager.h
//  bluetooth-lock
//
//  Created by Sumit on 26/01/15.
//  Copyright (c) 2015 sumit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LockManager.h"

@interface BluetoothManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralObject;
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) LockManager *locKManagerObject;


//+ (BluetoothManager *)sharedInstance;

- (void) discoverDevices;

@end
