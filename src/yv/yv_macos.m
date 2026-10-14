#include "yv_macos.h"

#include <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>

NSString *APP_NAME = @"yv";

void yv_show_error(const char *message) {
    [NSApplication sharedApplication];

    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = APP_NAME;
    alert.informativeText =
        message != NULL
            ? [NSString stringWithUTF8String:message]
            : @"An unknown error occurred.";
    [alert runModal];
}

void yv_macos_window_set_min_size(void *native_window, double width, double height) {
    if (native_window == NULL) return;
    NSWindow *window = (__bridge NSWindow *)native_window;
    [window setMinSize:NSMakeSize(width, height)];
}

void yv_macos_menu_setup(void) {
    NSApplication *app = [NSApplication sharedApplication];
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"Main Menu"];

    // 1. Application Menu
    NSMenuItem *applicationMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:applicationMenuItem];

    NSMenu *applicationMenu = [[NSMenu alloc] initWithTitle:APP_NAME];
    [mainMenu setSubmenu:
        applicationMenu
        forItem:
            applicationMenuItem];

    // About
    NSString *strAboutItem = @"About ";
    NSMenuItem *aboutItem =
        [[NSMenuItem alloc]
            initWithTitle:[strAboutItem stringByAppendingString:APP_NAME]
            action:@selector(orderFrontStandardAboutPanel:)
            keyEquivalent:@""];
    [aboutItem setTarget:app];
    [applicationMenu addItem:aboutItem];

    // Separator
    [applicationMenu addItem:[NSMenuItem separatorItem]];

    // Quit
    NSString *strQuitItem = @"Quit ";
    NSMenuItem *quitItem =
        [[NSMenuItem alloc]
            initWithTitle:[strQuitItem stringByAppendingString:APP_NAME]
            action:@selector(terminate:)
            keyEquivalent:@"q"];

    [quitItem setTarget:app];
    [quitItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    [applicationMenu addItem:quitItem];

    // 2. Window Menu
    NSMenuItem *windowMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:windowMenuItem];

    NSMenu *windowMenu = [[NSMenu alloc]initWithTitle:@"Window"];
    [mainMenu setSubmenu:windowMenu forItem:windowMenuItem];

    // Minimize
    NSMenuItem *minimizeItem =
        [[NSMenuItem alloc]
            initWithTitle:@"Minimize"
            action:@selector(performMiniaturize:)
            keyEquivalent:@"m"];
    [minimizeItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    [windowMenu addItem:minimizeItem];

    // Close Window
    NSMenuItem *closeItem =
        [[NSMenuItem alloc]
            initWithTitle:@"Close Window"
            action:@selector(performClose:)
            keyEquivalent:@"w"];
    [closeItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    [windowMenu addItem:closeItem];

    // Register
    [app setMainMenu:mainMenu];
    [app setWindowsMenu:windowMenu];
}