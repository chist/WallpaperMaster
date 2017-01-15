//
//  DesktopUpdater.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 05.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class DesktopUpdater {
    var timer: Timer? = nil
    var imageGetter: ImageGetterDelegate
    var currentWallpaper: DescribedImage? = nil
    var period: Double = 300
    var isRandom: Bool = true
    let saver = Saver()
    
    init(source: ImageSource) {
        // set default image source
        switch source {
        case .NatGeo:
            self.imageGetter = NatGeoCollection()
        case .yandex:
            self.imageGetter = YandexCollection()
        case .RGO:
            self.imageGetter = RGOCollection()
        case .saved:
            self.imageGetter = SavedCollection()
        }
        
        if PreferencesHolder().timeOption != 0 {
            // launch timer to update wallpapers automatically
            resetTimer()
            
            // update wallpaper immediately after launch
            self.updateWallpaper()
        }
        
        NSWorkspace.shared().notificationCenter.addObserver(self,
                                                            selector: #selector(spaceChanged),
                                                            name: NSNotification.Name.NSWorkspaceActiveSpaceDidChange,
                                                            object: nil)
    }
    
    @objc func spaceChanged() {
        DispatchQueue.global().async {
            do {
                let workspace = NSWorkspace.shared()
                let screen = NSScreen.main()!
                try workspace.setDesktopImageURL(Saver.currentImageURL, for: screen, options: [:])
            } catch let error {
                ErrorHandler.record(error.localizedDescription)
            }
        }
    }
    
    @objc func updateWallpaper() {
        DispatchQueue.global().async {
            // download new wallpaper
            let wallpaper: DescribedImage
            if self.isRandom {
                wallpaper = self.imageGetter.getRandomImage()
            } else {
                wallpaper = self.imageGetter.getImageOfTheDay()
            }
            if wallpaper.image == nil {
                return
            }
            self.currentWallpaper = wallpaper
            
            // save wallpaper image to disk
            self.saver.save(wallpaper: wallpaper)
            
            // update wallpaper
            self.spaceChanged()
        }
        
        resetTimer()
    }
    
    func resetTimer(){
        self.timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: self.period, target: self, selector: #selector(updateWallpaper), userInfo: nil, repeats: true)
    }
    
    func addToFavourites() {
        if let wallpaper = currentWallpaper {
            saver.saveToFavourites(wallpaper)
        }
    }
}
