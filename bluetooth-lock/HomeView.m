//
//  HomeView.m
//  bluetooth-lock
//
//  Created by Sumit on 24/01/15.
//  Copyright (c) 2015 sumit. All rights reserved.
//

#import "HomeView.h"
#import "LockManager.h"

@implementation HomeView

- (id) initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if(self){
        [self initializeViews];
    }
    return self;
}

- (void) initializeViews{
    [self createLockButton];
}

- (void) createLockButton{
    NSRect frame = NSMakeRect(0, 0, 100, 100);
    NSButton *lockButton = [[NSButton alloc] initWithFrame:frame];
    [lockButton setTarget:self];
    [lockButton setAction:@selector(discoverDevices)];
    [self addSubview:lockButton];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//discover devices
- (void) discoverDevices{
    self.bluetoothManager = [[BluetoothManager alloc] init];
//    self.bluetoothManager = [BluetoothManager sharedInstance];
    [self.bluetoothManager discoverDevices];
}

- (void) unlock{
    [LockManager unlockScreen];
}

@end