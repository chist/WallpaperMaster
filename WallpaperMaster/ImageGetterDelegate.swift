//
//  ImageGetterDelegate.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 04.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

protocol ImageGetterDelegate {
    func getRandomImage() -> NSImage?
    func getImageOfTheDay() -> NSImage?
}
