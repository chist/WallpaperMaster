//
//  ViewController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 04.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let desktopUpdater = DesktopUpdater()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        desktopUpdater.imageGetter = NatGeoCollection()
    }
}

