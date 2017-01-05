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
    var imageGetter: ImageGetterDelegate? = nil
    
    init() {
        // create folder for the application where all the wallpapers will be saved
        let directory    = FileManager.SearchPathDirectory.documentDirectory
        let mask         = FileManager.SearchPathDomainMask.userDomainMask
        let paths        = NSSearchPathForDirectoriesInDomains(directory, mask, true)
        let documentsDir = paths.first
        self.appFolder   = URL(fileURLWithPath: documentsDir!).appendingPathComponent("WallpaperMaster")
        let FMDefault    = FileManager.default
        try? FMDefault.createDirectory(at: appFolder, withIntermediateDirectories: false, attributes: [:])

        self.imageGetter = NatGeoCollection()
        
        // update wallpaper immediately after launch
        self.updateWallpaper()
        
        // launch timer to update wallpapers automatically
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(updateWallpaper), userInfo: nil, repeats: true)
    }
    
    @objc func updateWallpaper() {
        // download new wallpaper
        let newImage = self.imageGetter?.getRandomImage()
        
        // create random name for the image and save it
        let num = arc4random()
        let imageURL = appFolder.appendingPathComponent("\(num).jpg")
        newImage?.savePNG(imageURL.path)
        
        // set image as desktop wallpaper
        do {
            let workspace = NSWorkspace.shared()
            let screen = NSScreen.main()!
            try workspace.setDesktopImageURL(imageURL, for: screen, options: [:])
        } catch let error {
            print(error)
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
            print("Error saving collage.");
        }
    }
}
