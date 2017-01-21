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
    internal var timer: Timer?   = nil
    internal var imageGetter: ImageGetterDelegate
    private  var currentWallpaper: DescribedImage? = nil
    internal var period: Double  = 300.0
    internal var isRandom: Bool  = true
    private  let saver           = Saver()
    private  let maxFailureCount = 2
    
    init(source: ImageSource) {
        // set default image source
        switch source {
        case .NatGeo:
            self.imageGetter = NatGeoCollection()
        case .yandex:
            self.imageGetter = YandexCollection()
        case .RGO:
            self.imageGetter = RGOCollection()
        case .bing:
            self.imageGetter = BingCollection()
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

    @objc private func spaceChanged() {
        // update wallpaper when user moved to another desktop space
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
    
    @objc internal func updateWallpaper() {
        DispatchQueue.global().async {
            // do several attempts in case current and previous images are the same
            var triesCount: Int = 0
            while triesCount < self.maxFailureCount {
                triesCount = triesCount + 1
                
                // download new wallpaper
                let wallpaper: DescribedImage
                if self.isRandom {
                    wallpaper = self.imageGetter.getRandomImage()
                } else {
                    wallpaper = self.imageGetter.getImageOfTheDay()
                }
                if wallpaper.image == nil {
                    continue
                }
                // compare with previous wallpaper
                if let current = self.currentWallpaper {
                    if current.name == wallpaper.name {
                        continue
                    }
                }
                
                self.currentWallpaper = wallpaper
                
                // save wallpaper image to disk
                self.saver.save(wallpaper: wallpaper)
                
                // update wallpaper
                self.spaceChanged()

                break
            }
        }
        
        resetTimer()
    }
    
    internal func resetTimer() {
        self.timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: self.period, target: self, selector: #selector(updateWallpaper), userInfo: nil, repeats: true)
    }
    
    internal func addToFavourites() {
        // save current wallpaper to folder with favourites
        if let wallpaper = currentWallpaper {
            saver.saveToFavourites(wallpaper)
        }
    }
}
