//
//  SettingsWindowController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 15.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class SettingsWindowController: NSWindowController {

    var generalTabButton: NSToolbarItem!
    var pathTabButton: NSToolbarItem!
    
    @IBOutlet var subViewController: NSViewController!
    
    @IBAction func tabChanged(sender: AnyObject?) {
        if sender as? NSToolbarItem == generalTabButton {
            
        } else if sender as? NSToolbarItem == pathTabButton {
            
        }
    }
}
