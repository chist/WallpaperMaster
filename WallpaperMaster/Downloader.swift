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
    func getImage(from link: String) -> NSImage? {
        do {
            let data = try Data(contentsOf: URL(string: link)!)
            let image = NSImage(data: data)
            return image
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
