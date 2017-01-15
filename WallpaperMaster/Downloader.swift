//
//  Downloader.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 07.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class Downloader {
    let saver = Saver()
    
    // download image from the Internet and add link and generated name as a description
    func getImage(from link: String) -> DescribedImage {
        do {
            let data = try Data(contentsOf: URL(string: link)!)
            let image = NSImage(data: data)
            return DescribedImage(image, from: link)
        } catch let error {
            print(error.localizedDescription)
            return DescribedImage(nil, from: "")
        }
    }
    
    // choose random image from folder
    func getFavouriteImage() -> DescribedImage {
        return saver.selectFavouriteImage()
    }
}
