//
//  PreferencesHolder.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 08.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesHolder {
    let defaultTimeOption  : Int         = 1
    let defaultSourceOption: ImageSource = ImageSource.NatGeo
    
    var timeOption:   Int {
        return UserDefaults.standard.object(forKey: "timeOption") as! Int
    }
    var sourceOption: ImageSource {
        let option = UserDefaults.standard.object(forKey: "sourceOption") as! Int
        return ImageSource(rawValue: option)!
    }
    
    init() {
        if UserDefaults.standard.object(forKey: "timeOption") == nil {
            UserDefaults.standard.set(defaultTimeOption, forKey: "timeOption")
        }
        if UserDefaults.standard.object(forKey: "sourceOption") == nil {
            UserDefaults.standard.set(defaultSourceOption, forKey: "sourceOption")
        }
    }
    
    func setTimeOption(_ option: Int) {
        UserDefaults.standard.set(option, forKey: "timeOption")
    }
    
    func setSourceOption(_ option: Int) {
        UserDefaults.standard.set(option, forKey: "sourceOption")
    }
}
