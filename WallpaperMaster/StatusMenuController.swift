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
    
    var options = [ImageSource : NSMenuItem]()
    let preferencesHolder = PreferencesHolder()
    var desktopUpdater: DesktopUpdater? = nil
    
    // periods of wallpaper update in seconds
    let times: [(Int, String)] = [(5, "minutes"), (15, "minutes"), (30, "minutes"),
                                  (1, "hour"), (3, "hours"), (6, "hours"), (1, "day")]
    
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
        
        // create dictionary of image sources and option items
        options[.NatGeo] = NatGeoOption
        options[.RGO]    = RGOOption
        options[.yandex] = yandexOption
        options[.bing]   = bingOption
        options[.saved]  = savedOption
        
        // mark default image source
        var defaultSource = preferencesHolder.sourceOption
        if defaultSource == .saved && Saver.reviseFavouriteImages().count == 0 {
            defaultSource = .NatGeo
        }
        updateItemStates(current: defaultSource)
        
        // mark savedOption as active / inactive
        if Saver.reviseFavouriteImages().count > 0 {
            savedOption.isEnabled = true
        } else {
            savedOption.isEnabled = false
        }
        
        // update time interval
        let defaultTime = preferencesHolder.timeOption
        updateTimeInterval(timeSubmenu.item(at: defaultTime)!)
        
        // initialize desktopUpdater
        desktopUpdater = DesktopUpdater(source: defaultSource)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        // place app window into focus
        if NSApplication.shared().windows.count > 1 {
            NSApp.activate(ignoringOtherApps: true)
        }
        
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
    
    func updateItemStates(current: ImageSource) {
        // mark current source option with tick
        for (key, value) in options {
            value.state = (key == current) ? 1 : 0
        }
        
        // enable / disable "Get photo of the day" option
        statusBarMenu.item(at: 1)?.isEnabled = (current != .saved)
    }
    
    @IBAction func NatGeoIsChosen(_ sender: NSMenuItem) {
        updateItemStates(current: .NatGeo)
        desktopUpdater!.imageGetter = NatGeoCollection()
        preferencesHolder.setSourceOption(.NatGeo)
    }
    
    @IBAction func YandexIsChosen(_ sender: NSMenuItem) {
        updateItemStates(current: .yandex)
        desktopUpdater!.imageGetter = YandexCollection()
        preferencesHolder.setSourceOption(.yandex)
    }
    
    @IBAction func RGOIsChosen(_ sender: NSMenuItem) {
        updateItemStates(current: .RGO)
        desktopUpdater!.imageGetter = RGOCollection()
        preferencesHolder.setSourceOption(.RGO)
    }

    @IBAction func bingIsChosen(_ sender: NSMenuItem) {
        updateItemStates(current: .bing)
        desktopUpdater!.imageGetter = BingCollection()
        preferencesHolder.setSourceOption(.bing)
    }
    
    @IBAction func savedIsChosen(_ sender: AnyObject) {
        updateItemStates(current: .saved)
        desktopUpdater!.imageGetter = SavedCollection()
        preferencesHolder.setSourceOption(.saved)
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
