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
    var imageGetter: ImageGetterDelegate? = nil
    var currentWallpaper: DescribedImage? = nil
    var period: Double = 300
    var isRandom: Bool = true
    let saver = Saver()
    
    init() {
        self.imageGetter = NatGeoCollection()
        
        // launch timer to update wallpapers automatically
        resetTimer()
        
        // update wallpaper immediately after launch
        self.updateWallpaper()
    }
    
    @objc func updateWallpaper() {
        if imageGetter == nil {
            return
        }
        
        DispatchQueue.global().async {
            // download new wallpaper
            let wallpaper: DescribedImage
            if self.isRandom {
                wallpaper = self.imageGetter!.getRandomImage()
            } else {
                wallpaper = self.imageGetter!.getImageOfTheDay()
            }
            if wallpaper.image == nil {
                return
            }
            
            self.currentWallpaper = wallpaper
            
            self.saver.save(wallpaper: wallpaper)
            let imagePath = self.saver.currentImageURL.relativePath
            
            let script = "function wallpaper() { \nsqlite3 ~/Library/Application\\ Support/Dock/desktoppicture.db \"update data set value = '$1'\" && killall Dock\n}\nwallpaper " + imagePath
            
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", script]
            task.launch()
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

extension NSImage {
    var imagePNGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    
    func savePNG(_ path:String) {
        do {
            if let url = URL(string: path) {
                try imagePNGRepresentation.write(to: url);
            } else {
                print("Error: path is underfined.");
            }
        } catch {
            print("Error: image saving failed.");
        }
    }
}
