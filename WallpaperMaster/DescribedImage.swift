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
    let name: String
    
    init(_ image: NSImage?, from link: String) {
        self.image = image
        self.link = link
        self.name = "\(abs(link.hashValue)).jpg"
    }
    
    init() {
        self.image = nil
        self.link = ""
        self.name = ""
    }
}
