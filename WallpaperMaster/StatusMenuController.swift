//
//  StatusMenuController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 07.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusBarMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        statusItem.title = "WM"
        statusItem.menu = statusBarMenu
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
