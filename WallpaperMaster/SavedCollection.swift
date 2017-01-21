//
//  SavedCollection.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 15.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class SavedCollection: ImageGetterDelegate {
    private let downloader = Downloader()
    
    // option is unavailable for that collection
    func getImageOfTheDay() -> DescribedImage {
        // return empty object
        return DescribedImage()
    }
    
    func getRandomImage() -> DescribedImage {
        return downloader.getFavouriteImage()
    }
}
