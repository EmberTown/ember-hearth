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

struct Browser {
    var identifier: String
    var path: String
    var name: String
    var icon: NSImage
}

func ==(left: Browser, right: Browser) -> Bool {
    return left.identifier == right.identifier
}

let defaultBrowserKey = "defaultBrowserKey"

class GeneralSettingsViewController: NSViewController, MASPreferencesViewController {
    #if RELEASE
    var updater = SUUpdater()
    #endif
    
    @IBOutlet var automaticUpdatesCheckbox: NSButton!
    @IBOutlet var showStatusItemCheckbox: NSButton!
    @IBOutlet var shortcutView: MASShortcutView!
    @IBOutlet var browserButton: NSPopUpButton!
    
    let knownBrowsers = ["com.operasoftware.Opera", "com.google.Chrome", "com.apple.Safari", "org.mozilla.firefox", "com.google.Chrome.canary"] as Set
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    var installedBrowsers: [Browser] = []
    var defaultBrowser: Browser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if RELEASE
        automaticUpdatesCheckbox.bind("value", toObject: updater, withKeyPath: "automaticallyChecksForUpdates", options: nil)
        #else
        automaticUpdatesCheckbox.target = self
        automaticUpdatesCheckbox.action = "noUpdatesInDebug"
        #endif
        
        let defaultBrowserIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(defaultBrowserKey) ?? LSCopyDefaultHandlerForURLScheme("https").takeUnretainedValue() as! String
        let httpsers = Set(LSCopyAllHandlersForURLScheme("https").takeUnretainedValue() as! [String])
        let installedBrowserIdentifiers = Array(httpsers.intersect(self.knownBrowsers))
        for identifier in installedBrowserIdentifiers {
            let paths = (LSCopyApplicationURLsForBundleIdentifier(identifier, nil).takeUnretainedValue() as! [NSURL])
            let path = paths.first!.absoluteString!
            let name = path.stringByDeletingPathExtension.lastPathComponent.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let icon = NSWorkspace.sharedWorkspace().iconForFile(path.stringByReplacingOccurrencesOfString("file://", withString: "", options: NSStringCompareOptions.allZeros, range: nil).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            
            let smallIcon = NSImage(size: NSSize(width: 16, height: 16))
            smallIcon.lockFocus()
            icon.drawInRect(NSRect(x: 0, y: 0, width: smallIcon.size.width, height: smallIcon.size.height))
            smallIcon.unlockFocus()
            
            let browser = Browser(identifier: identifier, path: path, name: name, icon: smallIcon)
            installedBrowsers.append(browser)
            if identifier == defaultBrowserIdentifier {
                defaultBrowser = browser
            }
        }
        installedBrowsers = installedBrowsers.sorted { $0.name < $1.name }
        
        browserButton.menu?.removeAllItems()
        for browser in installedBrowsers {
            let item = NSMenuItem()
            item.title = browser.name
            item.image = browser.icon
            browserButton.menu?.addItem(item)
            
            if NSUserDefaults.standardUserDefaults().stringForKey(defaultBrowserKey) != nil && NSUserDefaults.standardUserDefaults().stringForKey(defaultBrowserKey) == browser.identifier {
                browserButton.selectItem(item)
            } else if browser == defaultBrowser! {
                browserButton.selectItem(item)
            }
        }

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
    
    @IBAction func changedBrowser(sender: AnyObject?) {
        let browser = installedBrowsers[browserButton.indexOfSelectedItem]
        println("Set default browser to  \(browser.identifier)")
        NSUserDefaults.standardUserDefaults().setValue(browser.identifier, forKey: defaultBrowserKey)
    }
}
