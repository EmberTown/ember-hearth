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



    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        NSUserDefaults.standardUserDefaults().removeObjectForKey("projects")
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
        setupDependencies { (success) -> () in
            if !success {
                println("Could not set up dependencies.")
                return
            }
            
            var panel = NSSavePanel()
            
        }
    }
    
    func setupDependencies(completion:(success:Bool) -> ()) {
        
        // Fetching node…
        
        var alert = NSAlert()
        alert.messageText = "This will install the following tools:"
        alert.informativeText = "* node\n* NPM\n* Bower\n* Phantom.js\n* Ember-CLI"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("OK")
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: { (response: NSModalResponse) -> Void in
            println("Response: \(response)")
            if response == 1001 { // OK
                self.setupNode({ (success) -> () in
                    completion(success: false)
                });
            }
        })
    }
    
    func setupNode(completion:(success:Bool) -> ()) {
        
        let isInstalled = Node.isInstalled()
        println("Is node installed? \(isInstalled)")
        if isInstalled {
            completion(success: true)
        }
        
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
}

