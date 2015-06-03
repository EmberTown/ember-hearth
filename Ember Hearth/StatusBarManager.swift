//
//  StatusBarManager.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 26.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
import MASShortcut

let _sharedManager = StatusBarManager()

class StatusBarManager: NSObject {
    class var sharedManager: StatusBarManager {
        get {return _sharedManager}
    }
    
    var statusBarItem: NSStatusItem?
    var statusBarMenu: NSMenu?
    var nameMenuItem: NSMenuItem?
    var runServerMenuItem: NSMenuItem?
    var terminateMenuItem: NSMenuItem?
    
    let noProjectString = "No project selected"
    
    var appDelegate: AppDelegate {
        get {
            return NSApplication.sharedApplication().delegate as! AppDelegate
        }
    }
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStarted:", name: "serverStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStopped:", name: "serverStopped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStoppedWithError:", name: "serverStoppedWithError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStarting:", name: "serverStarting", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "activeProjectSet:", name: "activeProjectSet", object: nil)
    }
    
    func showStatusBarItem() {
        let statusIcon = NSImage(named: "StatusBarIconIdle")
        statusIcon?.setTemplate(true)
        statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength( -2 ) // NSSquareStatusItemLength
        statusBarItem?.button?.setAccessibilityTitle("Ember Hearth")
        statusBarItem?.button?.image = statusIcon
        statusBarMenu = NSMenu(title: "Ember Hearth")
        
        let title = appDelegate.activeProject?.name ?? noProjectString
        nameMenuItem = NSMenuItem(title: "\(title)", action: nil, keyEquivalent: "")
        nameMenuItem?.enabled = false
        statusBarMenu?.addItem(nameMenuItem!)

        runServerMenuItem = NSMenuItem(title: "Run Server", action: "toggleServer:", keyEquivalent: "")
        statusBarMenu?.addItem(runServerMenuItem!)
        
        let separator = NSMenuItem.separatorItem()
        statusBarMenu?.addItem(separator)
        
        terminateMenuItem = NSMenuItem(title: "Quit Ember Hearth", action: "terminate:", keyEquivalent: "")
        statusBarMenu?.addItem(terminateMenuItem!)
        
        statusBarMenu?.autoenablesItems = false
        runServerMenuItem?.enabled = true
        statusBarItem?.menu = statusBarMenu
        
        MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey(appDelegate.runServerHotKey, toAction: { () -> Void in
            self.appDelegate.toggleServer(nil)
        })
    }
    
    func hideStatusBarItem() {
        if statusBarItem != nil {
            NSStatusBar.systemStatusBar().removeStatusItem(statusBarItem!)
        }
    }
    
    // MARK: Notification handling
    func serverStarting(notification: NSNotification?) {
        updateStatusBarButton("StatusBarIconStarting", accessibilityTitle: "Ember Hearth - Starting Server")
        runServerMenuItem?.enabled = true
        runServerMenuItem?.title = "Stop booting server"
    }
    
    func serverStarted(notification: NSNotification?) {
        updateStatusBarButton("StatusBarIconRunning", accessibilityTitle: "Ember Hearth - Running Server")
        runServerMenuItem?.enabled = true
        runServerMenuItem?.title = "Stop server"
    }
    
    func serverStopped(notification: NSNotification?) {
        updateStatusBarButton("StatusBarIconIdle", accessibilityTitle: "Ember Hearth")
        runServerMenuItem?.enabled = true
        runServerMenuItem?.title = "Run server"
    }
    
    func serverStoppedWithError(notification: NSNotification?) {
        updateStatusBarButton("StatusBarIconError", accessibilityTitle: "Ember Hearth - Server Failed Miserably")
        runServerMenuItem?.enabled = true
        runServerMenuItem?.title = "Run server"
    }
    
    func activeProjectSet(notification: NSNotification?) {
        nameMenuItem?.title = (notification?.object as? Project)?.name ?? noProjectString
    }

    // MARK: UI Updates
    func updateStatusBarButton(imageName: String, accessibilityTitle: String) {
        let image = NSImage(named: imageName)
        image?.setTemplate(true)
        statusBarItem?.button?.image = image
        statusBarItem?.button?.setAccessibilityTitle(accessibilityTitle)
    }
    
}
