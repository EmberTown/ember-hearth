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
    var activeProject: Project? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("activeProjectSet", object: activeProject)
            toggleProjectMenus()
        }
    }
    var projectNameController: ProjectNameWindowController?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
#if DEBUG
        addDebugMenu()
#endif
    }
    
    func toggleProjectMenus() {
        var mainMenu = NSApplication.sharedApplication().mainMenu
        let projectActive = activeProject != nil
        for item in mainMenu!.itemArray as [NSMenuItem] {
            if item.tag == 1 { // 1 is set for menus reqiring an active project
                item.enabled = projectActive
            }
        }
    }
    
    func addDebugMenu() {
        var mainMenu = NSApplication.sharedApplication().mainMenu
        var debugMenu = NSMenu(title: "Debug")

        debugMenu.addItem(NSMenuItem(title: "Install node.js", action: "installNode:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Install NPM", action: "installNPM:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Install Ember CLI", action: "installEmberCLI:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Install Bower", action: "installBower:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Install Phantom.js", action: "installPhantomjs:", keyEquivalent: ""))
        
        debugMenu.addItem(NSMenuItem(title: "Node.js version", action: "nodeVersion:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "NPM version", action: "npmVersion:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Bower version", action: "bowerVersion:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Ember CLI version", action: "emberCLIVersion:", keyEquivalent: ""))
        debugMenu.addItem(NSMenuItem(title: "Phantom.js version", action: "phantomJSVersion:", keyEquivalent: ""))
        
        
        let debugMenuItem = NSMenuItem(title: "Debug", action: nil, keyEquivalent: "")
        mainMenu?.insertItem(debugMenuItem, atIndex: 5)
        mainMenu?.setSubmenu(debugMenu, forItem: debugMenuItem)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func createNewProject (sender: AnyObject) {
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
            panel.message = "Select a location for the project folder (the folder \(name) will be created)"
            panel.maxSize = CGSize(width: 500.0, height: 500.0)
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
                    var dependencyManager = DependencyManager()
                    dependencyManager.setupDependencies {(success) -> () in
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
                let path = (panel.URLs.first! as NSURL).path!
                println("Picked project path \(path)")
                // Create project with new folder
                var dependencyManager = DependencyManager()
                dependencyManager.setupDependencies { (success) -> () in
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
            NSApp.beginSheet(sheet.window!, modalForWindow: NSApplication.sharedApplication().mainWindow!, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)

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
                    NSApp.endSheet(sheet.window!)
                }

            })
        }
        return project
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
    
    //MARK: Debug menu
    func installNode (sender: AnyObject) {
        var node = Node()
        node.install { (success) -> () in
            println("Installed node with success: \(success)")
        }
    }
    
    func installNPM (sender: AnyObject) {
        var npm = NPM()
        npm.install { (success) -> () in
            println("Installed npm with success: \(success)")
        }
    }
    
    func installEmberCLI (sender: AnyObject) {
        var ember = EmberCLI()
        ember.install { (success) -> () in
            println("Installed Ember CLI with success: \(success)")
        }
    }
    
    func installBower (sender: AnyObject) {
        var bower = Bower()
        bower.install { (success) -> () in
            println("Installed Bower with success: \(success)")
        }
    }
    
    func installPhantomjs (sender: AnyObject) {
        var phantom = PhantomJS()
        phantom.install { (success) -> () in
            println("Installed Phantom JS with success: \(success)")
        }
    }
    
    func nodeVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = "Node.js version: \(Node.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func npmVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = "NPM version: \(NPM.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func bowerVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = "Bower version: \(Bower.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func emberCLIVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = "Ember CLI version: \(EmberCLI.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
    
    func phantomJSVersion (sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = "Phantom.js version: \(PhantomJS.version()!)"
        alert.beginSheetModalForWindow(NSApplication.sharedApplication().mainWindow!, completionHandler: nil)
    }
}
