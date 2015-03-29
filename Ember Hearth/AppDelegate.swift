//
//  AppDelegate.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var activeProject: Dictionary<String, AnyObject>?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //TODO: Remove this debug thing
        NSUserDefaults.standardUserDefaults().removeObjectForKey("projects")
        
        
//        var testProject: Dictionary<String, AnyObject> = Dictionary()
//        testProject["usesPodStructure"] = true
//        NSUserDefaults.standardUserDefaults().setObject([testProject], forKey: "projects")
//        
//        var projects = NSUserDefaults.standardUserDefaults().objectForKey("projects") as NSArray
//        var firstProject = projects.firstObject as Dictionary<String, AnyObject>!
//        let usesPods = firstProject["usesPodStructure"] as Bool
//        println("pods? \(usesPods)")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func createNewProject (sender: AnyObject) {
        println("Show new project dialog")
        
        
        var panel = NSOpenPanel()
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: {[weak self] (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let path = (panel.URLs.first! as NSURL).path!
                println("Picked project path \(path)")
                // Create project with new folder
                self?.setupDependencies {[weak self] (success) -> () in
                    if !success {
                        println("Could not set up dependencies.")
                        return
                    }
                    
                    self?.activeProject = self?.createProject(path, name: "")
                }
            }
        })
    }
    
    func setupDependencies(completion:(success:Bool) -> ()) {
        
        // Fetching node…
        
        var alert = NSAlert()
        alert.messageText = "This will install the following tools:"
        alert.informativeText = "* node\n* NPM\n* Bower\n* Phantom.js\n* Ember-CLI"
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: { (response: NSModalResponse) -> Void in
            
            
            println("Response: \(response)")
            if response == 1000 { // OK
                var sheet = ProgressWindowController()
                let result = NSBundle.mainBundle().loadNibNamed("ProgressPanel", owner: sheet, topLevelObjects: nil)
                println("Result: \(result)")
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

    @IBAction func openExistingProject (sender: AnyObject) {
        var panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.beginWithCompletionHandler { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let path: NSURL? = panel.URLs.first as? NSURL
                var projects: Array<Dictionary<String, AnyObject>> = []
                if NSUserDefaults.standardUserDefaults().objectForKey("projects") != nil {
                    projects = NSUserDefaults.standardUserDefaults().objectForKey("projects")! as Array<Dictionary<String, AnyObject>>
                }
                
                if path != nil {
                    // Check if project is an ember CLI projects
                    if NSFileManager.defaultManager().fileExistsAtPath(path!.URLByAppendingPathComponent(".ember-cli").path!) {
                        println("Adding ember-cli project from \(path!.path!)")
                        var project = ["path":path!.path!]
                        projects.append(project)
                    } else {
                        let filePath = path!.URLByAppendingPathComponent(".ember-cli").path!
                        println("Not an ember-cli project! (\(filePath))")
                    }
                }
                
                NSUserDefaults.standardUserDefaults().setObject(projects, forKey: "projects")
            }
        }
    }
    
    func createProject(path: String, name: String) -> Dictionary<String, AnyObject> {
        var project = ["path":path, "name":name]
        var projects: Array<Dictionary<String, AnyObject>>? = NSUserDefaults.standardUserDefaults().objectForKey("projects") as? Array
        if projects == nil {
            projects = []
        }
        projects!.append(project)
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: "projects")
        return project
    }
}

