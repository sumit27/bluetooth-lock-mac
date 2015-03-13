//
//  LockManager.m
//  bluetooth-lock
//
//  Created by Sumit on 24/01/15.
//  Copyright (c) 2015 sumit. All rights reserved.
//

#import "LockManager.h"

@implementation LockManager


#pragma mark - Lock Screen
+ (void)lockScreen;
{
    
    int screenSaverDelayUserSetting = 0;
    
    screenSaverDelayUserSetting = [self readScreensaveDelay];
    
    if (screenSaverDelayUserSetting != 0) {
        // if the delay isn't already 0, temporarily set it to 0 so the screen locks immediately.
        [self setScreensaverDelay:0];
        [self touchSecurityPreferences];
    }
    
    io_registry_entry_t r = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler");
    if (r) {
        IORegistryEntrySetCFProperty(r, CFSTR("IORequestIdle"),kCFBooleanTrue);
        IOObjectRelease(r);
    }
    
    if (screenSaverDelayUserSetting != 0) {
        [self setScreensaverDelay:screenSaverDelayUserSetting];
        [self launchAndQuitSecurityPreferences];
    }
}

+ (void)touchSecurityPreferences{
    // necessary for screen saver setting changes to take effect on file-vault-enabled systems
    // NOTE: this *only* works when going from non-zero settings of askForPasswordDelay to zero.
    
    NSAppleScript *kickSecurityPreferencesScript = [[NSAppleScript alloc] initWithSource: @"tell application \"System Events\" to tell security preferences to set require password to wake to true"];
    [kickSecurityPreferencesScript executeAndReturnError:nil];
}

+ (void)launchAndQuitSecurityPreferences;
{
    // necessary for screen saver setting changes to take effect on file-vault-enabled systems when going from a askForPasswordDelay setting of zero to a non-zero setting
    NSAppleScript *kickSecurityPreferencesScript = [[NSAppleScript alloc] initWithSource:
                                                    @"tell application \"System Preferences\"\n"
                                                    @"     tell anchor \"General\" of pane \"com.apple.preference.security\" to reveal\n"
                                                    @"     activate\n"
                                                    @"end tell\n"
                                                    @"delay 0\n"
                                                    @"tell application \"System Preferences\" to quit"];
    [kickSecurityPreferencesScript executeAndReturnError:nil];
    
}

+ (int)readScreensaveDelay;
{
    NSArray *arguments = @[@"read",@"com.apple.screensaver",@"askForPasswordDelay"];
    
    NSTask *readDelayTask = [[NSTask alloc] init];
    [readDelayTask setArguments:arguments];
    [readDelayTask setLaunchPath: @"/usr/bin/defaults"];
    
    NSPipe *pipe = [NSPipe pipe];
    [readDelayTask setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [readDelayTask launch];
    NSData *resultData = [file readDataToEndOfFile];
    NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    return resultString.intValue;
}

+ (void)setScreensaverDelay:(int)delay;
{
    NSArray *arguments = @[@"write",@"com.apple.screensaver",@"askForPasswordDelay", [NSString stringWithFormat:@"%i", delay]];
    NSTask *resetDelayTask = [[NSTask alloc] init];
    [resetDelayTask setArguments:arguments];
    [resetDelayTask setLaunchPath: @"/usr/bin/defaults"];
    [resetDelayTask launch];
}



#pragma mark - Unlock Screen
+ (void) unlockScreen{

    NSString * st = @"tell application \"System Events\" to tell security preferences to set require password to wake to false";
    NSAppleScript *aps = [[NSAppleScript alloc] initWithSource:st];
    
    [aps executeAndReturnError:nil];
    [self runUnlockScript];
}

+ (void) runUnlockScript
{
    io_registry_entry_t r = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler");
    if (r) {
        IORegistryEntrySetCFProperty(r, CFSTR("IORequestIdle"),kCFBooleanFalse);
        IOObjectRelease(r);
    }
    
}

@end
