//
//  ViewController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 08.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Foundation
import Cocoa

class ContactViewController: NSViewController {
    private let donationLink = "https://money.yandex.ru/to/410014893378724"
    
    @IBAction func coffeeButtonClicked(_ sender: NSButton) {
        if let donationURL = URL(string: donationLink) {
            NSWorkspace.shared().open(donationURL)
        }
    }
    
}
