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
import MASShortcut

class GeneralSettingsViewController: NSViewController, MASPreferencesViewController {
    #if RELEASE
    var updater = SUUpdater()
    #endif
    
    @IBOutlet var automaticUpdatesCheckbox: NSButton!
    @IBOutlet var showStatusItemCheckbox: NSButton!
    @IBOutlet var shortcutView: MASShortcutView!
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if RELEASE
        automaticUpdatesCheckbox.bind("value", toObject: updater, withKeyPath: "automaticallyChecksForUpdates", options: nil)
        #else
        automaticUpdatesCheckbox.target = self
        automaticUpdatesCheckbox.action = "noUpdatesInDebug"
        #endif
        
        shortcutView.associatedUserDefaultsKey = appDelegate.runServerHotKey
        
        showStatusItemCheckbox.bind("value",
            toObject: NSUserDefaultsController.sharedUserDefaultsController(),
            withKeyPath: "values.\(appDelegate.hideStatusBarItemKey)",
            options: [NSValueTransformerNameBindingOption:NSNegateBooleanTransformerName]) // Flip bool value
    }
    
    // MARK: MASPreferencesViewController
    var toolbarItemImage = NSImage(named: "NSPreferencesGeneral")
    var toolbarItemLabel = "General"
    
    func noUpdatesInDebug() {
        println("Debug builds doesn't load Sparkle and doesn't provide automatic updates. This button does nothing here.")
    }
    
    @IBAction func toggleStatusItem(sender: AnyObject?) {
        if NSUserDefaults.standardUserDefaults().boolForKey(appDelegate.hideStatusBarItemKey) {
            StatusBarManager.sharedManager.hideStatusBarItem()
        } else {
            StatusBarManager.sharedManager.showStatusBarItem()
        }
    }
}
