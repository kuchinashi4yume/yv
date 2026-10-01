#include "yv_macos_menu.h"

#import <Cocoa/Cocoa.h>

void yv_macos_menu_setup(void) {
    NSApplication *app = [NSApplication sharedApplication];
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"Main Menu"];

    // 1. Application Menu
    NSMenuItem *applicationMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:applicationMenuItem];

    NSMenu *applicationMenu = [[NSMenu alloc] initWithTitle:@"yv"];
    [mainMenu setSubmenu:
        applicationMenu
        forItem:
            applicationMenuItem];

    // About
    NSMenuItem *aboutItem =
        [[NSMenuItem alloc]
            initWithTitle:@"About yv"
            action:@selector(orderFrontStandardAboutPanel:)
            keyEquivalent:@""];
    [aboutItem setTarget:app];
    [applicationMenu addItem:aboutItem];

    // Separator
    [applicationMenu addItem:[NSMenuItem separatorItem]];

    // Quit
    NSMenuItem *quitItem =
        [[NSMenuItem alloc]
            initWithTitle:@"Quit yv"
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