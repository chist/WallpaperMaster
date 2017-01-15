//
//  MainViewController.swift
//  WallpaperMaster
//
//  Created by Ivan Chistyakov on 16.01.17.
//  Copyright © 2017 Ivan Chistyakov. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet var menuControl: NSSegmentedControl!
    @IBOutlet var containerView: NSView!
    @IBOutlet var versionLabel: NSTextField!
    
    let sourceVC  = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SourceVC") as! NSViewController
    let contactVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ContactVC") as! NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.stringValue = self.getAppVersion()
        
        self.sourcesButtonPressed()
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
    
    @IBAction func menuPressed(_ sender: NSSegmentedControl) {
        if menuControl.selectedSegment == 0 {
            self.sourcesButtonPressed()
        } else {
            self.contactButtonPressed()
        }
    }
    
    func sourcesButtonPressed() {
        contactVC.removeFromParentViewController()
        contactVC.view.removeFromSuperview()
        self.addChildViewController(sourceVC)
        self.containerView.addSubview(sourceVC.view)
    }
    
    func contactButtonPressed() {
        sourceVC.removeFromParentViewController()
        sourceVC.view.removeFromSuperview()
        self.addChildViewController(contactVC)
        self.containerView.addSubview(contactVC.view)
    }
}
