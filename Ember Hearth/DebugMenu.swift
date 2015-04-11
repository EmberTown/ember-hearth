//
//  DebugMenu.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 08.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class DebugMenu: NSMenu {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override init(title aTitle: String) {
        super.init(title: aTitle)
        self.configure()
    }
    
    class func debugItem(forMenu menu: NSMenu) -> NSMenuItem {
        var item = NSMenuItem(title: "Debug", action: nil, keyEquivalent: "")
        menu.setSubmenu(DebugMenu(title: "Debug"), forItem: item)
        return item
    }
    
    func configure() {
        self.removeAllItems()
        
        self.addItem(NSMenuItem(title: "Install node.js", action: "installNode", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Install NPM", action: "installNPM", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Install Ember CLI", action: "installEmberCLI", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Install Bower", action: "installBower", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Install Phantom.js", action: "installPhantomjs", keyEquivalent: ""))
        
        self.addItem(NSMenuItem.separatorItem())
        
        self.addItem(NSMenuItem(title: "Node.js version", action: "nodeVersion", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "NPM version", action: "npmVersion", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Bower version", action: "bowerVersion", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Ember CLI version", action: "emberCLIVersion", keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Phantom.js version", action: "phantomJSVersion", keyEquivalent: ""))
        
        self.addItem(NSMenuItem.separatorItem())
        
        self.addItem(NSMenuItem(title: "Show dependency status", action: "dependencyStatus", keyEquivalent: ""))

        // For some reason, the default target of NSMenuItem isn't self.
        for item in self.itemArray as! [NSMenuItem] {
            item.target = self
        }
    }
    
    func installNode() {
        var node = Node()
        node.install { (success) -> () in
            println("Installed node with success: \(success)")
        }
    }
    
    func installNPM() {
        var npm = NPM()
        npm.install { (success) -> () in
            println("Installed npm with success: \(success)")
        }
    }
    
    func installEmberCLI() {
        var ember = EmberCLI()
        ember.install { (success) -> () in
            println("Installed Ember CLI with success: \(success)")
        }
    }
    
    func installBower() {
        var bower = Bower()
        bower.install { (success) -> () in
            println("Installed Bower with success: \(success)")
        }
    }
    
    func installPhantomjs() {
        var phantom = PhantomJS()
        phantom.install { (success) -> () in
            println("Installed Phantom JS with success: \(success)")
        }
    }
    
    func nodeVersion() {
        let alert = NSAlert()
        alert.messageText = "Node.js version: \(Node.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func npmVersion() {
        let alert = NSAlert()
        alert.messageText = "NPM version: \(NPM.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func bowerVersion() {
        let alert = NSAlert()
        alert.messageText = "Bower version: \(Bower.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func emberCLIVersion() {
        let alert = NSAlert()
        alert.messageText = "Ember CLI version: \(EmberCLI.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func phantomJSVersion() {
        let alert = NSAlert()
        alert.messageText = "Phantom.js version: \(PhantomJS.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func dependencyStatus() {
        var dpManager = DependencyManager()
        dpManager.showDependencyStatus()
    }
}