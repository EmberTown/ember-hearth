//
//  GeneralSettingsViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 18.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
import MASPreferences

class GeneralSettingsViewController: NSViewController, MASPreferencesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: MASPreferencesViewController
    var toolbarItemImage = NSImage(named: "NSPreferencesGeneral")
    var toolbarItemLabel = "General"
}
