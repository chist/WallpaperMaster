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
    
    private let sourceVC  = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SourceVC")) as! NSViewController
    private let contactVC = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ContactVC")) as! NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display current app version and build number
        versionLabel.stringValue = self.getAppVersion()
        
        // load initial view
        self.sourcesButtonPressed()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // place app window into focus
        self.view.window?.makeKey()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func getAppVersion() -> String {
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
    
    private func cleanContainerView() {
        sourceVC.removeFromParentViewController()
        sourceVC.view.removeFromSuperview()
        contactVC.removeFromParentViewController()
        contactVC.view.removeFromSuperview()
    }
    
    private func sourcesButtonPressed() {
        self.cleanContainerView()
        self.addChildViewController(sourceVC)
        self.containerView.addSubview(sourceVC.view)
    }
    
    private func contactButtonPressed() {
        self.cleanContainerView()
        self.addChildViewController(contactVC)
        self.containerView.addSubview(contactVC.view)
    }
}
