//
//  AppDelegate.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
#if RELEASE
import Sparkle
#endif
import MASPreferences
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var projects: [Project]?
    var activeProject: Project? {
        didSet {
            if activeProject != nil {
                NSNotificationCenter.defaultCenter().postNotificationName("activeProjectSet", object: activeProject)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("noActiveProject", object: activeProject)
            }
            toggleProjectMenus()
        }
    }
    var projectNameController: ProjectNameWindowController?
    var preferensesWindowController: NSWindowController?
    var statusBarItem: NSStatusItem?
    var statusBarMenu: NSMenu?
    
    #if DEBUG
    var debugMenu = DebugMenu(title: "Debug")
    #else
    var updater: SUUpdater?
    #endif
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        #if DEBUG
        addDebugMenu()
        #else
        updater = SUUpdater()
        #endif
        
        let tomster = NSImage(named: "StatusBarIcon")
        tomster?.setTemplate(true)
        statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength( -2 ) // NSSquareStatusItemLength
        statusBarItem?.button?.setAccessibilityTitle("Ember Hearth")
        statusBarItem?.button?.image = tomster
        statusBarMenu = NSMenu(title: "Ember Hearth")
        statusBarMenu?.addItem(NSMenuItem(title: "Run Server", action: "toggleServer:", keyEquivalent: "e"))
        statusBarMenu?.autoenablesItems = false
        statusBarMenu?.itemAtIndex(0)?.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
        statusBarMenu?.itemAtIndex(0)?.enabled = true
        statusBarItem?.menu = statusBarMenu
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStarted:", name: "serverStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStopped:", name: "serverStopped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStopped:", name: "serverStoppedWithError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStarting:", name: "serverStarting", object: nil)
        
        let shortcut = MASShortcut(keyCode: UInt(kVK_ANSI_E), modifierFlags: UInt(statusBarMenu!.itemAtIndex(0)!.keyEquivalentModifierMask))
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: { () in
            if self.statusBarMenu?.itemAtIndex(0)?.enabled != nil && self.statusBarMenu!.itemAtIndex(0)!.enabled {
                self.toggleServer(nil)
            }
        })
    }
    
    @IBAction func toggleServer(sender: AnyObject?) {
        ProjectController.sharedInstance.toggleServer(sender)
    }
    
    func serverStarting(notification: NSNotification?) {
        statusBarMenu?.itemAtIndex(0)?.enabled = false
    }
    
    func serverStarted(notification: NSNotification?) {
        statusBarMenu?.itemAtIndex(0)?.enabled = true
        statusBarMenu?.itemAtIndex(0)?.title = "Stop Server"
    }
    
    func serverStopped(notification: NSNotification?) {
        statusBarMenu?.itemAtIndex(0)?.enabled = true
        statusBarMenu?.itemAtIndex(0)?.title = "Run Server"
    }
    
    func toggleProjectMenus() {
        var mainMenu = NSApplication.sharedApplication().mainMenu
        let projectActive = activeProject != nil
        for item in mainMenu!.itemArray as! [NSMenuItem] {
            if item.tag == 1 { // 1 is set for menus reqiring an active project
                item.enabled = projectActive
            }
        }
    }
    
    func addDebugMenu() {
        var mainMenu = NSApplication.sharedApplication().mainMenu
        if mainMenu != nil {
            mainMenu!.insertItem(DebugMenu.debugItem(forMenu: mainMenu!), atIndex: 5)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        println("Terminating")
        self.stopAllServers()
    }

    func stopAllServers() {
        if projects != nil {
            for project in projects! {
                project.stopServer()
            }
        }
    }

    @IBAction func buildDev(sender: AnyObject?) {
        if self.activeProject != nil {
            var ember = EmberCLI()
            let path = self.activeProject!.path!
            ember.build(path, type: .development, completion: { (result: String?) -> () in
                println("Built ember: \(result)")
            })
        }
    }

    @IBAction func buildProd(sender: AnyObject?) {
        if self.activeProject != nil {
            var ember = EmberCLI()
            let path = self.activeProject!.path!
            ember.build(path, type: .development, completion: { (result: String?) -> () in
                println("Built ember: \(result)")
            })
        }
    }
    
    @IBAction func showSettings(sender: AnyObject?) {
        self.preferensesWindowController = nil
        
        var general = NSStoryboard(name: "Settings", bundle: nil)?.instantiateControllerWithIdentifier("GeneralSettings") as! GeneralSettingsViewController
        general.identifier = "General"
        var paths = NSStoryboard(name: "Settings", bundle: nil)?.instantiateControllerWithIdentifier("PathSettings") as! PathSettingsViewController
        paths.identifier = "Paths"
        
        self.preferensesWindowController = MASPreferencesWindowController(viewControllers:[general, paths], title: "Settings")
        self.preferensesWindowController?.showWindow(nil)
    }
    
    @IBAction func checkForUpdates(sender: AnyObject?) {
        #if DEBUG
        var alert = NSAlert()
        alert.messageText = "No updates in debug mode"
        alert.addButtonWithTitle("OK")
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
        #else
        if let updater = self.updater {
            updater.checkForUpdates(sender)
        }
        #endif
    }
    
    @IBAction func createProject(sender: AnyObject?) {
        ProjectController.sharedInstance.createProject(sender)
    }
    
    @IBAction func openProject(sender: AnyObject?) {
        ProjectController.sharedInstance.openProject(sender)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
