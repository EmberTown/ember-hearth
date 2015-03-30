//
//  AppDelegate.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ProjectNameWindowDelegate {
    var activeProject: Dictionary<String, AnyObject>?
    var projectNameController: ProjectNameWindowController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        //TODO: Remove this debug thing
        NSUserDefaults.standardUserDefaults().removeObjectForKey("projects")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func createNewProject (sender: AnyObject) {
        println("Show new project dialog")
        
        projectNameController = ProjectNameWindowController()
        projectNameController?.delegate = self
        NSBundle.mainBundle().loadNibNamed("NewProjectTitle", owner: projectNameController, topLevelObjects: nil)
        NSApp.beginSheet(projectNameController!.window!, modalForWindow: NSApplication.sharedApplication().mainWindow!, modalDelegate: self, didEndSelector: nil, contextInfo: nil)
    }
    
    func nameSet(name: String) {
        println("Name set to \(name)")
        self.projectNameController?.cancel(nil)
        self.projectNameController = nil
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            var panel = NSOpenPanel()
            panel.canCreateDirectories = true
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false
            weak var weakself = self
            panel.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: {(result: Int) -> Void in
                if result == NSFileHandlingPanelOKButton {
                    let path = (panel.URLs.first! as NSURL).path!
                    println("Picked project path \(path)")
                    // Create project with new folder
                    weakself?.setupDependencies {(success) -> () in
                        if !success {
                            println("Could not set up dependencies.")
                            return
                        }
                        
                        weakself?.activeProject = weakself?.createProject(path, name: name, runEmberInstall:true)
                    }
                }
            })
        }
    }
    
    @IBAction func openExistingProject (sender: AnyObject) {
        var panel = NSOpenPanel()
        panel.canCreateDirectories = false
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
                    
                    self?.activeProject = self?.createProject(path, name: "", runEmberInstall:false)
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
    
    func createProject(path: String, name: String, runEmberInstall: Bool) -> Dictionary<String, AnyObject> {
        var project = ["path":path, "name":name]
        if runEmberInstall {
            project = ["path":"\(path)/\(name)", "name":name]
        }
        var projects: Array<Dictionary<String, AnyObject>>? = NSUserDefaults.standardUserDefaults().objectForKey("projects") as? Array
        if projects == nil {
            projects = []
        }
        projects!.append(project)
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: "projects")
        
        if runEmberInstall {
            var ember = EmberCLI()
            ember.createProject(path, name: name, completion: { (success) -> () in
                if !success {
                    println("Error creating ember project!")
                }
            })
        }
        return project
    }
    
    @IBAction func buildDev(sender: AnyObject?) {
        if self.activeProject != nil {
            var ember = EmberCLI()
            let path = self.activeProject!["path"] as String
            ember.build(path, type: .development, completion: { (result: String?) -> () in
                println("Built ember: \(result)")
            })
        }
    }
    
    @IBAction func buildProd(sender: AnyObject?) {
        if self.activeProject != nil {
            var ember = EmberCLI()
            let path = self.activeProject!["path"] as String
            ember.build(path, type: .development, completion: { (result: String?) -> () in
                println("Built ember: \(result)")
            })
        }
    }
}

