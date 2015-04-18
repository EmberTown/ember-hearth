//
//  GeneralSettingsViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 18.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
import MASPreferences
#if RELEASE
import Sparkle
#endif

class GeneralSettingsViewController: NSViewController, MASPreferencesViewController {
    #if RELEASE
    var updater = SUUpdater()
    #endif
    @IBOutlet var automaticUpdatesCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if RELEASE
        automaticUpdatesCheckbox.bind("value", toObject: updater, withKeyPath: "automaticallyChecksForUpdates", options: nil)
        #else
        automaticUpdatesCheckbox.target = self
        automaticUpdatesCheckbox.action = "noUpdatesInDebug"
        #endif
    }
    
    // MARK: MASPreferencesViewController
    var toolbarItemImage = NSImage(named: "NSPreferencesGeneral")
    var toolbarItemLabel = "General"
    
    func noUpdatesInDebug() {
        println("Debug builds doesn't load Sparkle and doesn't provide automatic updates. This button does nothing here.")
    }
}
