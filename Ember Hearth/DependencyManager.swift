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
        switch Node.isInstalled() {
        case true: needed.append("✅ Node.js")
        default: needed.append("❌ Node.js")
        }
        
        switch NPM.isInstalled() {
        case true: needed.append("✅ NPM")
        default: needed.append("❌ NPM")
        }
        
        switch Bower.isInstalled() {
        case true: needed.append("✅ Bower")
        default: needed.append("❌ Bower")
        }
        
        switch PhantomJS.isInstalled() {
        case true: needed.append("✅ PhantomJS")
        default: needed.append("❌ PhantomJS")
        }
        
        switch EmberCLI.isInstalled() {
        case true: needed.append("✅ Ember-CLI")
        default: needed.append("❌ Ember-CLI")
        }
        return needed
    }
    
    func setupDependencies(completion:(success:Bool) -> ()) {
        var alert = NSAlert()
        alert.messageText = "Dependencies:"
        let needed = listNeededInstalls()
        var neededString = ""
        for string in needed {
            neededString += "\(string)\n"
        }
        neededString += "\nEmber Hearth will install any missing dependencies automatically."
        alert.informativeText = neededString
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: { (response: NSModalResponse) -> Void in
            
            
            println("Response: \(response)")
            if response == 1000 { // OK
                var sheet = ProgressWindowController()
                NSBundle.mainBundle().loadNibNamed("ProgressPanel", owner: sheet, topLevelObjects: nil)
                sheet.label.stringValue = "Installing Node.js…"
                NSApp.beginSheet(sheet.window!, completionHandler: nil)
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    var node = Node()
                    node.installIfNeeded({ (success) -> () in
                        if !success {
                            completion(success: false)
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            sheet.progressIndicator.doubleValue = 0.2
                            sheet.label.stringValue = "Installing NPM…"
                        })
                        var npm = NPM()
                        npm.installIfNeeded({ (success) -> () in
                            if !success {
                                completion(success: false)
                                return
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                sheet.progressIndicator.doubleValue = 0.4
                                sheet.label.stringValue = "Installing Bower…"
                            })
                            var bower = Bower()
                            bower.installIfNeeded({ (success) -> () in
                                if !success {
                                    completion(success: false)
                                    return
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    sheet.progressIndicator.doubleValue = 0.6
                                    sheet.label.stringValue = "Installing PhantomJS…"
                                })
                                var phantom = PhantomJS()
                                phantom.installIfNeeded({ (success) -> () in
                                    if !success {
                                        completion(success: false)
                                        return
                                    }
                                
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        sheet.progressIndicator.doubleValue = 0.8
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
                                                sheet.window!.endSheet(sheet.window!)
                                                completion(success: true)
                                            }
                                        })
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
