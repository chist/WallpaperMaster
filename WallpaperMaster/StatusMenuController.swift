//
//  StatusMenuController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 07.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSMenuDelegate {
    @IBOutlet var statusBarMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let timeSubmenu = NSMenu(title: "Set update time")
    
    @IBOutlet weak var NatGeoOption: NSMenuItem!
    @IBOutlet weak var yandexOption: NSMenuItem!
    @IBOutlet weak var RGOOption:    NSMenuItem!
    @IBOutlet weak var bingOption:   NSMenuItem!
    @IBOutlet weak var savedOption:  NSMenuItem!
    
    let preferencesHolder = PreferencesHolder()
    
    // periods of wallpaper update in seconds
    let times: [(Int, String)] = [(5, "minutes"), (15, "minutes"), (30, "minutes"),
                                  (1, "hour"), (3, "hours"), (6, "hours"), (1, "day")]
    
    var desktopUpdater: DesktopUpdater? = nil
    
    override func awakeFromNib() {
        // add menu to status bar
        statusItem.title = "WM"
        statusItem.menu = statusBarMenu
        
        // set menuController as a delegate to be notified when it opens
        statusBarMenu.delegate = self
        
        // create submenu for the choice of time interval
        if let reserved = statusBarMenu.item(withTag: 5) {
            statusBarMenu.setSubmenu(timeSubmenu, for: reserved)
            
            let disableTitle = "Disable auto updates"
            let submenuItem = NSMenuItem(title: disableTitle, action: #selector(updateTimeInterval), keyEquivalent: String())
            submenuItem.target = self
            submenuItem.tag = 0
            submenuItem.state  = 0
            timeSubmenu.addItem(submenuItem)
            
            for (index, element) in times.enumerated() {
                let fullTitle = "\(element.0) " + element.1
                let submenuItem = NSMenuItem(title: fullTitle, action: #selector(updateTimeInterval), keyEquivalent: String())
                submenuItem.target = self
                submenuItem.state  = 0
                
                // enumerate items
                submenuItem.tag = index + 1
                
                timeSubmenu.addItem(submenuItem)
            }
        }
        
        // mark default image source
        let defaultSourceOption = preferencesHolder.sourceOption
        var checkedSourceOption = defaultSourceOption
        switch defaultSourceOption {
        case .NatGeo:
            NatGeoOption.state = 1
        case .yandex:
            yandexOption.state = 1
        case .RGO:
            RGOOption.state    = 1
        case .bing:
            bingOption.state   = 1
        case .saved:
            if Saver.reviseFavouriteImages().count == 0 {
                NatGeoOption.state  = 1
                checkedSourceOption = .NatGeo
            } else {
                savedOption.state   = 1
            }
        }
        
        // mark savedOption as active / inactive
        if Saver.reviseFavouriteImages().count > 0 {
            savedOption.isEnabled = true
        } else {
            savedOption.isEnabled = false
        }
        
        // update time interval
        let defaultTimeOption = preferencesHolder.timeOption
        updateTimeInterval(timeSubmenu.item(at: defaultTimeOption)!)
        
        // initialize desktopUpdater
        desktopUpdater = DesktopUpdater(source: checkedSourceOption)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        // disable favFolder as option if it is empty
        if Saver.reviseFavouriteImages().count > 0 {
            self.savedOption.isEnabled = true
        } else {
            self.savedOption.isEnabled = false
        }
    }
    
    @IBAction func nextImage(_ sender: NSMenuItem) {
        statusBarMenu.item(at: 0)?.title = "Next random image"
        statusBarMenu.item(at: 4)?.isEnabled = true
        desktopUpdater!.isRandom = true
        desktopUpdater!.updateWallpaper()
        desktopUpdater!.resetTimer()
    }
    
    @IBAction func getPhotoOfTheDay(_ sender: NSMenuItem) {
        statusBarMenu.item(at: 0)?.title = "Continue with random photos"
        statusBarMenu.item(at: 4)?.isEnabled = false
        desktopUpdater!.isRandom = false
        desktopUpdater!.updateWallpaper()
        desktopUpdater!.timer?.invalidate()
    }
    
    @IBAction func saveImage(_ sender: NSMenuItem) {
        desktopUpdater?.addToFavourites()
    }
    
    @IBAction func NatGeoIsChosen(_ sender: NSMenuItem) {
        NatGeoOption.state = 1
        yandexOption.state = 0
        RGOOption.state    = 0
        bingOption.state   = 0
        savedOption.state  = 0
        desktopUpdater!.imageGetter = NatGeoCollection()
        preferencesHolder.setSourceOption(.NatGeo)
        
        // enable "Get photo of the day" option
        statusBarMenu.item(at: 1)?.isEnabled = true
    }
    
    @IBAction func YandexIsChosen(_ sender: NSMenuItem) {
        NatGeoOption.state = 0
        yandexOption.state = 1
        RGOOption.state    = 0
        bingOption.state   = 0
        savedOption.state  = 0
        desktopUpdater!.imageGetter = YandexCollection()
        preferencesHolder.setSourceOption(.yandex)
        
        // enable "Get photo of the day" option
        statusBarMenu.item(at: 1)?.isEnabled = true
    }
    
    @IBAction func RGOIsChosen(_ sender: NSMenuItem) {
        NatGeoOption.state = 0
        yandexOption.state = 0
        RGOOption.state    = 1
        bingOption.state   = 0
        savedOption.state  = 0
        desktopUpdater!.imageGetter = RGOCollection()
        preferencesHolder.setSourceOption(.RGO)
        
        // enable "Get photo of the day" option
        statusBarMenu.item(at: 1)?.isEnabled = true
    }

    @IBAction func bingIsChosen(_ sender: NSMenuItem) {
        NatGeoOption.state = 0
        yandexOption.state = 0
        RGOOption.state    = 0
        bingOption.state   = 1
        savedOption.state  = 0
        desktopUpdater!.imageGetter = BingCollection()
        preferencesHolder.setSourceOption(.bing)
        
        // enable "Get photo of the day" option
        statusBarMenu.item(at: 1)?.isEnabled = true
    }
    
    @IBAction func savedIsChosen(_ sender: AnyObject) {
        NatGeoOption.state = 0
        yandexOption.state = 0
        RGOOption.state    = 0
        bingOption.state   = 0
        savedOption.state  = 1
        desktopUpdater!.imageGetter = SavedCollection()
        preferencesHolder.setSourceOption(.saved)
        
        // disable "Get photo of the day" option
        statusBarMenu.item(at: 1)?.isEnabled = false
    }
    
    
    func updateTimeInterval(_ sender: NSMenuItem) {
        let tag = sender.tag
        
        // mark current time interval
        for item in timeSubmenu.items {
            item.state = (item.tag == tag) ? 1 : 0
        }
        // save chosen option to settings
        preferencesHolder.setTimeOption(tag)
        
        // if user disabled auto update
        if sender.tag == 0 {
            desktopUpdater?.timer?.invalidate()
            return
        }
        
        let element = times[tag - 1]
        
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
        
        desktopUpdater?.period = Double(element.0 * multiplier)
        desktopUpdater?.resetTimer()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
