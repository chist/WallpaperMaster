//
//  AppDelegate.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 04.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusBarMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    let desktopUpdater = DesktopUpdater()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = "WM"
        statusItem.menu = statusBarMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

}

