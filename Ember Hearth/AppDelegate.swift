//
//  AppDelegate.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ProjectNameWindowDelegate {
    var projects: [Project]?
    var activeProject: Project? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("activeProjectSet", object: activeProject)
            toggleProjectMenus()
        }
    }
    var projectNameController: ProjectNameWindowController?
    var preferensesWindowController: NSWindowController?
    var updater: SUUpdater?
    
    #if DEBUG
    var debugMenu = DebugMenu(title: "Debug")
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
        // Insert code here to tear down your application
    }

    @IBAction func createNewProject (sender: AnyObject) {
        projectNameController = ProjectNameWindowController()
        projectNameController?.delegate = self
        NSBundle.mainBundle().loadNibNamed("NewProjectTitle", owner: projectNameController, topLevelObjects: nil)
        NSApplication.sharedApplication().mainWindow!.beginSheet(projectNameController!.window!, completionHandler: nil)
    }

    func nameSet(name: String) {
        if let projectNameWindow = projectNameController?.window {
            projectNameWindow.orderOut(self)
            NSApplication.sharedApplication().mainWindow!.endSheet(projectNameWindow)
        }
        self.projectNameController?.cancel(nil)
        self.projectNameController = nil

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            var panel = NSOpenPanel()
            panel.message = "Select a location for the project folder (the folder \(name) will be created)"
            panel.maxSize = CGSize(width: 500.0, height: 500.0)
            panel.canCreateDirectories = true
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.allowsMultipleSelection = false
            weak var weakself = self
            panel.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: {(result: Int) -> Void in
                if result == NSFileHandlingPanelOKButton {
                    let path = (panel.URLs.first! as! NSURL).path!
                    println("Picked project path \(path)")
                    // Create project with new folder
                    var dependencyManager = DependencyManager()
                    dependencyManager.installDependencies {(success) -> () in
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
        weak var weakself = self
        panel.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let path = (panel.URLs.first! as! NSURL).path!
                println("Picked project path \(path)")
                // Create project with new folder
                var dependencyManager = DependencyManager()
                dependencyManager.installDependencies { (success) -> () in
                    if !success {
                        println("Could not set up dependencies.")
                        return
                    }

                    weakself?.activeProject = weakself?.createProject(path, name: nil, runEmberInstall:false)
                }
            }
        })
    }

    func createProject(path: String, name: String?, runEmberInstall: Bool) -> Project {
        var project = Project(name: name, path: path)
        if runEmberInstall && name != nil {
            project.path = project.path?.stringByAppendingPathComponent(name!)
        } else if name == nil {
            project.loadNameFromPath()
        }
        var projects: Array<Dictionary<String, AnyObject>>? = NSUserDefaults.standardUserDefaults().objectForKey("projects") as? Array
        if projects == nil {
            projects = []
        }
        projects!.append(project.dictionaryRepresentation())
        NSUserDefaults.standardUserDefaults().setObject(projects, forKey: "projects")

        if runEmberInstall {
            var sheet = ProgressWindowController()
            NSBundle.mainBundle().loadNibNamed("ProgressPanel", owner: sheet, topLevelObjects: nil)
            sheet.progressIndicator.indeterminate = true
            sheet.progressIndicator.startAnimation(nil)
            sheet.label.stringValue = "Setting up ember project files…"
            NSApplication.sharedApplication().mainWindow?.beginSheet(sheet.window!, completionHandler: nil)

            var ember = EmberCLI()
            ember.createProject(path, name: name!, completion: { (success) -> () in
                if !success {
                    println("Error creating ember project!")
                    sheet.label.stringValue = "Install failed."
                } else {
                    sheet.label.stringValue = "Success!"
                }
                let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    sheet.window!.orderOut(nil)
                    sheet.window!.endSheet(sheet.window!)
                }

            })
        }
        return project
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
        if let updater = self.updater {
            updater.checkForUpdates(sender)
        }
    }
}
