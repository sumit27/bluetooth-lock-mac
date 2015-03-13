//
//  HomeView.h
//  bluetooth-lock
//
//  Created by Sumit on 24/01/15.
//  Copyright (c) 2015 sumit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BluetoothManager.h"

@interface HomeView : NSView

@property (nonatomic, strong) BluetoothManager *bluetoothManager;

@end
