//
//  DescribedImage.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 07.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class DescribedImage {
    let image: NSImage?
    let link: String
    
    init(_ image: NSImage?, from link: String) {
        self.image = image
        self.link = link
    }
    
    init() {
        self.image = nil
        self.link = ""
    }
}
