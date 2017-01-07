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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = DesktopUpdater()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

