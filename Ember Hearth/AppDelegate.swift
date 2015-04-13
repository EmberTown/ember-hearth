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
        preferensesWindowController = NSStoryboard(name: "Settings", bundle: nil)?.instantiateInitialController() as? NSWindowController
        preferensesWindowController?.showWindow(nil)
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
}
