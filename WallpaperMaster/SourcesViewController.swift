//
//  SourcesViewController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 16.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class SourcesViewController: NSViewController {
    
    @IBAction func showSavedInFinder(_ sender: NSButton) {
        Saver().openFavourites()
    }
}
