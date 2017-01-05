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
        // создаём папку для хранения картинок
        let directory    = FileManager.SearchPathDirectory.documentDirectory
        let mask         = FileManager.SearchPathDomainMask.userDomainMask
        let paths        = NSSearchPathForDirectoriesInDomains(directory, mask, true)
        let documentsDir = paths.first
        appFolder        = URL(fileURLWithPath: documentsDir!).appendingPathComponent("WallpaperMaster")

        let FMDefault = FileManager.default
        try? FMDefault.createDirectory(at: appFolder, withIntermediateDirectories: false, attributes: [:])

        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(updateWallpaper), userInfo: nil, repeats: true)
    }
    
    @objc func updateWallpaper() {
        let newImage = self.imageGetter?.getRandomImage()
        
        let num = arc4random()
        let imageURL = appFolder.appendingPathComponent("\(num).jpg")
        newImage?.savePNG(imageURL.path)
        
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
