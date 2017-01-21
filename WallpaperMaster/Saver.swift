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
    static internal var appFolder:       URL    = Saver.initAppFolder()
    static internal var favFolder:       URL    = Saver.initFavFolder()
    static internal var currentImageURL: URL    = Saver.initCurrentImage()
    private let         maxAttempts:     Int    = 5
    private let         prefix:          String = "c"
    
    static func initAppFolder() -> URL {
        // create folder for the application where all the wallpapers will be saved
        let directory    = FileManager.SearchPathDirectory.documentDirectory
        let mask         = FileManager.SearchPathDomainMask.userDomainMask
        let paths        = NSSearchPathForDirectoriesInDomains(directory, mask, true)
        let documentsDir = paths.first
        let appFolder    = URL(fileURLWithPath: documentsDir!).appendingPathComponent("WallpaperMaster")
        let FMDefault    = FileManager.default
        try? FMDefault.createDirectory(at: appFolder, withIntermediateDirectories: false, attributes: [:])
        
        return appFolder
    }
    
    static private func initFavFolder() -> URL {
        // create subdirectory for favourites
        let FMDefault    = FileManager.default
        let favFolder        = Saver.appFolder.appendingPathComponent("Saved")
        try? FMDefault.createDirectory(at: favFolder, withIntermediateDirectories: false, attributes: [:])
        
        return favFolder
    }
    
    static private func initCurrentImage() -> URL {
        return Saver.appFolder.appendingPathComponent("current.png")
    }
    
    internal func save(wallpaper: DescribedImage) {
        // create folders in case they were deleted
        Saver.appFolder = Saver.initAppFolder()
        Saver.favFolder = Saver.initFavFolder()
        
        // determine current image file name (in case of restart)
        let fileManager = FileManager.default
        let enumerator  = fileManager.enumerator(atPath: Saver.appFolder.path)
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
                let fullPath = Saver.appFolder.appendingPathComponent(currentImagePath!).path
                try fileManager.removeItem(atPath: fullPath)
            }
            catch let error {
                ErrorHandler.record("Cannot delete image: " + error.localizedDescription)
            }
        }
        
        let curName = self.prefix + wallpaper.name
        Saver.currentImageURL = Saver.appFolder.appendingPathComponent(curName)
        wallpaper.image?.savePNG(to: Saver.currentImageURL)
    }
    
    internal func saveToFavourites(_ wallpaper: DescribedImage) {
        // create folders in case they were deleted
        Saver.appFolder = Saver.initAppFolder()
        Saver.favFolder = Saver.initFavFolder()
        
        // save image to folder on disk
        let imageURL = Saver.favFolder.appendingPathComponent(wallpaper.name)
        wallpaper.image?.savePNG(to: imageURL)
    }
    
    internal func openFavourites() {
        // create folders in case they were deleted
        Saver.appFolder = Saver.initAppFolder()
        Saver.favFolder = Saver.initFavFolder()
        
        NSWorkspace.shared().openFile(Saver.favFolder.path)
    }
    
    static internal func reviseFavouriteImages() -> [String] {
        let fileManager = FileManager.default
        let enumerator  = fileManager.enumerator(atPath: Saver.favFolder.path)
        var namesArray  = [String]()
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".jpg") || element.hasSuffix(".png") {
                namesArray.append(element)
            }
        }
        
        return namesArray
    }
    
    internal func selectFavouriteImage() -> DescribedImage {
        // array of all images' names in favFolder
        let namesArray = Saver.reviseFavouriteImages()
        
        if namesArray.count == 0 {
            ErrorHandler.record("No images in selected folder.")
        } else {
            var attempt: Int = 0
            while attempt < self.maxAttempts {
                attempt = attempt + 1
            
                // get random image URL
                let num = Int(arc4random()) % namesArray.count
                let imageURL = Saver.favFolder.appendingPathComponent(namesArray[num])
                
                // try one more time if current image is randomly selected again
                if (self.prefix + imageURL.lastPathComponent) == Saver.currentImageURL.lastPathComponent {
                    continue
                }
                
                // get NSImage from URL
                if let url = URL(string: imageURL.path) {
                    let fullURL = URL(string: "file://" + url.path)
                    if let image = NSImage(contentsOf: fullURL!) {
                        return DescribedImage(image, withName: namesArray[num])
                    }
                    ErrorHandler.record("Cannot access image by URL.")
                    return DescribedImage()

                } else {
                    ErrorHandler.record("Cannot unwrap image URL.")
                    return DescribedImage()
                }
            }
            return DescribedImage()
        }
        
        return DescribedImage()
    }
}

extension NSImage {
    var PNGRepresentation: NSData? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: NSBitmapImageFileType.PNG, properties: [:]) as NSData?
        } else {
            ErrorHandler.record("tiff or tiffData is nil.")
        }
        
        return nil
    }
    
    func savePNG(to url: URL) {
        if let png = self.PNGRepresentation {
            do {
                try png.write(to: url, options: .atomicWrite)
            } catch {
                ErrorHandler.record("Failed to write image to disk.")
            }
        } else {
            ErrorHandler.record("Failed to get PNG representation.")
        }
    }
}
