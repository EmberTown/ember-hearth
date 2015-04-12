//
//  MainSplitViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 12.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleSecondPane", name: "activeProjectSet", object: nil)
        toggleSecondPane()
    }
    
    func toggleSecondPane() {
        let secondItem = self.splitViewItems[1] as? NSSplitViewItem
        let delegate = NSApplication.sharedApplication().delegate as? AppDelegate
        if delegate?.activeProject != nil {
            secondItem?.canCollapse = false
            secondItem?.collapsed = false
        } else {
            secondItem?.canCollapse = true
            secondItem?.collapsed = true
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "activeProjectSet", object: nil)
    }
}
