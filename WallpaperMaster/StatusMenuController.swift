//
//  StatusMenuController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 07.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet var statusBarMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBOutlet weak var NatGeoOption: NSMenuItem!
    @IBOutlet weak var yandexOption: NSMenuItem!
    
    // periods of wallpaper update in seconds
    let times: [(Int, String)] = [(5, "minutes"), (15, "minutes"), (30, "minutes"),
                                  (1, "hour"), (3, "hours"), (6, "hours"), (1, "day")]
    
    let desktopUpdater = DesktopUpdater()
    
    override func awakeFromNib() {
        statusItem.title = "WM"
        statusItem.menu = statusBarMenu
        
        let timeSubmenu = NSMenu(title: "Set update time")
        if let reserved = statusBarMenu.item(withTag: 5) {
            statusBarMenu.setSubmenu(timeSubmenu, for: reserved)
            for element in times {
                let fullTitle = "\(element.0) " + element.1
                let submenuItem = NSMenuItem(title: fullTitle, action: #selector(updateTimeInterval), keyEquivalent: String())
                submenuItem.target = self
                
                // write time interval in seconds to tag attribute
                let multiplier: Int
                switch element.1 {
                case "second", "seconds":
                    multiplier = 1
                case "mimute", "minutes":
                    multiplier = 60
                case "hour", "hours":
                    multiplier = 60 * 60
                case "day", "days":
                    multiplier = 24 * 60 * 60
                default:
                    multiplier = 60
                }
                submenuItem.tag = element.0 * multiplier
                
                timeSubmenu.addItem(submenuItem)
            }
        }
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
        NatGeoOption.state = 1
        yandexOption.state = 0
        desktopUpdater.imageGetter = NatGeoCollection()
    }
    
    @IBAction func YandexIsChosen(_ sender: NSMenuItem) {
        NatGeoOption.state = 0
        yandexOption.state = 1
        desktopUpdater.imageGetter = YandexCollection()
    }
    
    @IBAction func updateTimeInterval(_ sender: NSMenuItem) {
        desktopUpdater.period = Double(sender.tag)
        desktopUpdater.resetTimer()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
