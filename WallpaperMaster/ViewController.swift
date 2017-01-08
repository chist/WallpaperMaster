//
//  ViewController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 08.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.stringValue = self.getAppVersion()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "Version: \(version) (\(build))"
    }
    
    @IBAction func showSavedInFinder(_ sender: NSButton) {
        Saver().openFavourites()
    }
    
}
