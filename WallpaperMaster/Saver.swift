//
//  Saver.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 08.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Saver {
    let appFolder:       URL
    let favFolder:       URL
    let currentImageURL: URL
    
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
        
        currentImageURL = self.appFolder.appendingPathComponent("current.jpg")
    }
    
    func save(wallpaper: DescribedImage) {
        wallpaper.image?.savePNG(currentImageURL.path)
    }
    
    func saveToFavourites(_ wallpaper: DescribedImage) {
        let imageURL = favFolder.appendingPathComponent(wallpaper.name)
        wallpaper.image?.savePNG(imageURL.path)
    }
    
    func openFavourites() {
        NSWorkspace.shared().openFile(favFolder.path)
    }
}
