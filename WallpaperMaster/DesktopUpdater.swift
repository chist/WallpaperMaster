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
    let appFolder: URL
    let favFolder: URL
    var timer: Timer? = nil
    var imageGetter: ImageGetterDelegate? = nil
    var currentWallpaper: DescribedImage? = nil
    var period: Double = 30
    var isRandom: Bool = true
    
    init() {
        // create folder for the application where all the wallpapers will be saved
        let directory    = FileManager.SearchPathDirectory.documentDirectory
        let mask         = FileManager.SearchPathDomainMask.userDomainMask
        let paths        = NSSearchPathForDirectoriesInDomains(directory, mask, true)
        let documentsDir = paths.first
        self.appFolder   = URL(fileURLWithPath: documentsDir!).appendingPathComponent("WallpaperMaster")
        let FMDefault    = FileManager.default
        try? FMDefault.createDirectory(at: appFolder, withIntermediateDirectories: false, attributes: [:])
        // create subdirectory for favourites
        favFolder        = appFolder.appendingPathComponent("Saved")
        try? FMDefault.createDirectory(at: favFolder, withIntermediateDirectories: false, attributes: [:])

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
            } else {
                self.currentWallpaper = wallpaper
            }
            
            let imageURL = self.appFolder.appendingPathComponent("current.jpg")
            wallpaper.image?.savePNG(imageURL.path)
            
            let script = "function wallpaper() { \nsqlite3 ~/Library/Application\\ Support/Dock/desktoppicture.db \"update data set value = '$1'\" && killall Dock\n}\nwallpaper " + imageURL.relativePath
            
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
            let name = wallpaper.name
            let imageURL = favFolder.appendingPathComponent(name)
            wallpaper.image?.savePNG(imageURL.path)
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
