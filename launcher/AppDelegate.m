//
//  AppDelegate.m
//  launcher
//
//  Created by @zensey on 15/08/2021.
//  Copyright © 2021 Mysterium Network. All rights reserved.
//
	
#import "AppDelegate.h"
#import "MainWindowDelegate.h"
#import "NetworkingModalDelegate.h"
#import "UpgradeModalDelegate.h"
#import "../gobridge/gobridge.h"

#include <sys/stat.h>
#include <copyfile.h>

LauncherState *mod = nil;

@implementation AppDelegate
@synthesize statusBarMenu;

- (void) applicationWillTerminate:(NSNotification *)aNotification {
    GoOnAppExit();
    NSLog(@"application exit >");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    mod = [[LauncherState alloc] init];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    mod.launcherVersionCurrent = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    GoInit((char*)[resourcePath UTF8String], (char*)[mod.launcherVersionCurrent UTF8String]);
    GoStart();
    

    if (!self.mainWin) {
        self.mainWin = [[MainWindowDelegate alloc] init];
    }
    NSWindow *modalWindow = [self.mainWin window];
    [self.mainWin showWindow:modalWindow];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationHandlerConfig:) name:@"new_config" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationHandlerState:) name:@"new_state" object:nil];

    
    NSStatusItem  *statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    statusItem.button.image = [NSImage imageNamed:@"icon"];
    statusItem.button.action = @selector(statusButtonClicked:);
    statusItem.button.target = self;
    [statusItem setMenu:self.statusBarMenu];
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)openNodeUIAction:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"http://localhost:4449"]];
}

- (void)statusButtonClicked:(id)sender{
}

- (void)notificationHandlerConfig:(NSNotification *) notification{
    //self.itemEnableNode = notification.userInfo[@"enabled"];
    NSLog(@"notificationHandlerConfig");
    [self setMenuItemState];
}

- (void)notificationHandlerState:(NSNotification *) notification{
    //self.itemEnableNode = notification.userInfo[@"enabled"];
}

- (IBAction)showMain:(id)sender {   
    NSWindow *modalWindow = [self.mainWin window];
    [self.mainWin showWindow:modalWindow];
}

- (IBAction)showUpgradeDlg:(id)sender {
    NSWindowController *modalWindowDelegate = [[UpgradeModalDelegate alloc] init];
    NSWindow *modalWindow = [modalWindowDelegate window];

    NSModalResponse response = [NSApp runModalForWindow:modalWindow ]; // relativeToWindow:self.window - deprecated
    if (response == NSModalResponseOK) {
        NSLog(@"NSModalResponseOK");
    }
}

- (IBAction)showNetworkingDlg:(id)sender {
    NSWindowController *modalWindowDelegate = [[ModalWindowDelegate alloc] init];
    NSWindow *modalWindow = [modalWindowDelegate window];

    NSModalResponse response = [NSApp runModalForWindow:modalWindow ]; // relativeToWindow:self.window - deprecated
    if (response == NSModalResponseOK) {
        NSLog(@"NSModalResponseOK");
    }
}

- (IBAction)enableNode:(id)sender {
    NSLog(@"enableNode %@", mod.enabled);

    mod.enabled = [mod.enabled isEqualToNumber:@0]? @1 : @0;
    [mod setState];
    [self setMenuItemState];
}

- (IBAction)enableNative:(NSButton*)sender {

    switch (sender.tag) {
    case 1:
        mod.backend = @"native";
        break;
    case 2:
        mod.backend = @"docker";
        break;
    }
    
    [mod setState];
    [self setMenuItemState];
}

- (void)setMenuItemState {
    [self.itemEnableNode setState:(NSControlStateValue) [mod.enabled intValue]];
    
    [self.itemEnableNative setState:(NSControlStateValue) [mod.backend isEqualToString:@"native"]?1:0];
    [self.itemEnableDocker setState:(NSControlStateValue) [mod.backend isEqualToString:@"docker"]?1:0];
}

@end
