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
    
    let desktopUpdater = DesktopUpdater()
    
    override func awakeFromNib() {
        statusItem.title = "WM"
        statusItem.menu = statusBarMenu
    }
    
    @IBAction func nextImage(_ sender: NSMenuItem) {
        desktopUpdater.isRandom = true
        desktopUpdater.updateWallpaper()
        desktopUpdater.resetTimer()
    }
    
    @IBAction func getPhotoOfTheDay(_ sender: NSMenuItem) {
        desktopUpdater.isRandom = false
        desktopUpdater.updateWallpaper()
        desktopUpdater.timer?.invalidate()
    }
    
    @IBAction func saveImage(_ sender: NSMenuItem) {
        desktopUpdater.addToFavourites()
    }
    
    @IBAction func NatGeoIsChosen(_ sender: NSMenuItem) {
        desktopUpdater.imageGetter = NatGeoCollection()
    }
    
    @IBAction func YandexIsChosen(_ sender: NSMenuItem) {
        desktopUpdater.imageGetter = YandexCollection()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
