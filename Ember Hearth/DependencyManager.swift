//
//  DependencyManager.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class DependencyManager {
    func listNeededInstalls () -> Array<String> {
        var needed: Array<String> = []
        if !Node.isInstalled() {
            needed.append("Node.js")
        }
        if !NPM.isInstalled() {
            needed.append("NPM")
        }
        if !Bower.isInstalled() {
            needed.append("Bower")
        }
        if !EmberCLI.isInstalled() {
            needed.append("Ember-CLI")
        }
        return needed
    }
    
    func setupDependencies(completion:(success:Bool) -> ()) {
        var alert = NSAlert()
        alert.messageText = "This will install the following tools:"
        alert.informativeText = "* node\n* NPM\n* Bower\n* Phantom.js\n* Ember-CLI"
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: { (response: NSModalResponse) -> Void in
            
            
            println("Response: \(response)")
            if response == 1000 { // OK
                var sheet = ProgressWindowController()
                NSBundle.mainBundle().loadNibNamed("ProgressPanel", owner: sheet, topLevelObjects: nil)
                sheet.label.stringValue = "Installing Node.js…"
                NSApp.beginSheet(sheet.window!, modalForWindow: NSApplication.sharedApplication().mainWindow!, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    var node = Node()
                    node.installIfNeeded({ (success) -> () in
                        if !success {
                            completion(success: false)
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sheet.progressIndicator.doubleValue = 0.25
                            sheet.label.stringValue = "Installing NPM…"
                        })
                        var npm = NPM()
                        npm.installIfNeeded({ (success) -> () in
                            if !success {
                                completion(success: false)
                                return
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                sheet.progressIndicator.doubleValue = 0.5
                                sheet.label.stringValue = "Installing Bower…"
                            })
                            var bower = Bower()
                            bower.installIfNeeded({ (success) -> () in
                                if !success {
                                    completion(success: false)
                                    return
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    sheet.progressIndicator.doubleValue = 0.75
                                    sheet.label.stringValue = "Installing Ember CLI…"
                                })
                                var ember = EmberCLI()
                                ember.installIfNeeded({ (success) -> () in
                                    if !success {
                                        completion(success: false)
                                        return
                                    }
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        sheet.progressIndicator.doubleValue = 1
                                        sheet.label.stringValue = "Success!"
                                        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                                            Int64(0.5 * Double(NSEC_PER_SEC)))
                                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                                            sheet.window!.orderOut(nil)
                                            NSApp.endSheet(sheet.window!)
                                            completion(success: true)
                                        }
                                    })
                                })
                            })
                        })
                    })
                }
            }
        })
    }
}
