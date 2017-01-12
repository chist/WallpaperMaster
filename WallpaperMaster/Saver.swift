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
    var currentImageURL: URL
    
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
        // determine current image file name (in case of restart)
        let fileManager = FileManager.default
        let enumerator  = fileManager.enumerator(atPath: appFolder.path)
        var currentImagePath: String? = nil
        while let element = enumerator?.nextObject() as? String {
            if element.hasPrefix("c") {
                currentImagePath = element
            }
        }
        if currentImagePath == nil {
            ErrorHandler.record("File with current image not found.")
        } else {
            do {
                let fullPath = appFolder.appendingPathComponent(currentImagePath!).path
                try fileManager.removeItem(atPath: fullPath)
            }
            catch let error {
                ErrorHandler.record("Cannot delete image: " + error.localizedDescription)
            }
        }
        
        currentImageURL = self.appFolder.appendingPathComponent("c\(Int(arc4random())).jpg")
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

extension NSImage {
    var imagePNGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    
    func savePNG(_ path:String) {
        do {
            if let url = URL(string: path) {
                try imagePNGRepresentation.write(to: url);
            } else {
               ErrorHandler.record("Error: path is underfined.");
            }
        } catch {
            ErrorHandler.record("Error: image saving failed.");
        }
    }
}
