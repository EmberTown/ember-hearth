//
//  ProjectController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 13.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

private let _projectControllerSharedInstance = ProjectController()

class ProjectController: NSObject, ProjectNameWindowDelegate, ProgressWindowDelegate, DependencyManagerDelegate {
    class var sharedInstance: ProjectController {
        get {return _projectControllerSharedInstance}
    }
    
    private weak var currentlyRunningTask: NSTask?
    
    var project: Project? {
        get {
            var delegate = NSApplication.sharedApplication().delegate as? AppDelegate
            return delegate?.activeProject
        }
        set {
            var delegate = NSApplication.sharedApplication().delegate as? AppDelegate
            delegate?.activeProject = newValue
        }
    }
    var appDelegate: AppDelegate {get {return NSApplication.sharedApplication().delegate as! AppDelegate}}
    var mainWindow: NSWindow {get {return NSApplication.sharedApplication().mainWindow!}}
    var serverOutput: String = ""
    var projectNameController: ProjectNameWindowController?
    
    // MARK: Creating and opening projects
    @IBAction func createProject(sender: AnyObject?) {
        projectNameController = ProjectNameWindowController(windowNibName: "NewProjectTitle")
        projectNameController?.delegate = self
        mainWindow.beginSheet(projectNameController!.window!, completionHandler: {(result: Int) -> Void in
            self.projectNameController?.cancel(nil)
            self.projectNameController = nil
        })
    }
    
    @IBAction func openProject(sender: AnyObject?) {
        var panel = NSOpenPanel.hearthFolderPicker(nil, allowFolderCreation: false)
        panel.beginSheetModalForWindow(mainWindow, completionHandler: { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let path = (panel.URLs.first! as! NSURL).path!
                // Create project with new folder
                var dependencyManager = DependencyManager()
                dependencyManager.delegate = self
                dependencyManager.installDependencies { (success) -> () in
                    if !success {
                        println("Could not set up dependencies.")
                        return
                    }
                    
                    self.project = self.addProject(path, name: nil, runEmberInstall:false)
                }
            }
        })
    }
    
    func nameSet(name: String) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            var panel = NSOpenPanel.hearthFolderPicker(name, allowFolderCreation: true)
            panel.beginSheetModalForWindow(self.mainWindow, completionHandler: { (result: Int) -> Void in
                if result == NSFileHandlingPanelOKButton {
                    let path = (panel.URLs.first! as! NSURL).path!
                    // Create project with new folder
                    var dependencyManager = DependencyManager()
                    dependencyManager.installDependencies {(success) -> () in
                        if !success {
                            println("Could not set up dependencies.")
                            return
                        }
                        
                        self.project = self.addProject(path, name: name, runEmberInstall:true)
                    }
                }
            })
        }
    }
    
    func addProject(path: String, name: String?, runEmberInstall: Bool) -> Project? {
        var project = Project(name: name, path: path)
        
        if let projects = appDelegate.projects {
            if let index = find(projects, project) {
                var alert = NSAlert()
                alert.messageText = "Project already loaded"
                alert.informativeText = "A project from the same path is already in the list."
                alert.beginSheetModalForWindow(mainWindow, completionHandler: { (response) -> Void in
                    self.project = projects[index]
                })
                return nil
            }
        }
        
        if !runEmberInstall && !NSFileManager.defaultManager().fileExistsAtPath(path.stringByAppendingPathComponent("package.json")) {
            var alert = NSAlert()
            alert.messageText = "No ember project in folder"
            alert.informativeText = "No ember project was found in this folder (looked for package.json)."
            alert.beginSheetModalForWindow(mainWindow, completionHandler: nil)
            return nil
        }
        
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
            sheet.delegate = self
            NSBundle.mainBundle().loadNibNamed("ProgressPanel", owner: sheet, topLevelObjects: nil)
            sheet.progressIndicator.indeterminate = true
            sheet.progressIndicator.startAnimation(nil)
            sheet.label.stringValue = "Setting up ember project files…"
            NSApplication.sharedApplication().mainWindow?.beginSheet(sheet.window!, completionHandler: nil)
            
            var ember = EmberCLI()
            self.currentlyRunningTask = ember.createProject(path, name: name!, completion: { (success) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if !success {
                        println("Error creating ember project!")
                        sheet.label.stringValue = "Install failed."
                        self.removeProject(project)
                    } else {
                        sheet.label.stringValue = "Success!"
                    }
                })
                
                sheet.window!.orderOut(nil)
                self.mainWindow.endSheet(sheet.window!)
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    if !success {
                        var alert = NSAlert()
                        alert.alertStyle = NSAlertStyle.WarningAlertStyle
                        alert.messageText = "Installation failed"
                        alert.informativeText = "Run ' cd \"\(project.path!.stringByDeletingLastPathComponent)\" && ember install \"\(project.name!)\" ' from Terminal to see what went wrong."
                        alert.beginSheetModalForWindow(self.mainWindow, completionHandler: nil)
                    }
                }
                
            })
        }
        return project
    }
    
    func removeProject(project: Project) {
        if self.project == project {
            self.project = nil
        }
        var projects: Array<Dictionary<String, AnyObject>>? = NSUserDefaults.standardUserDefaults().objectForKey("projects") as? Array
        if let projects = projects {
            var index: Int? = nil
            
            for (iteratorIndex, projectDict) in enumerate(projects) {
                if projectDict["path"] as? String == project.path {
                    index = iteratorIndex
                }
            }
            
            if let index = index {
                var tempArray = Array(projects)
                tempArray.removeAtIndex(index)
                NSUserDefaults.standardUserDefaults().setObject(tempArray, forKey: "projects")
                NSNotificationCenter.defaultCenter().postNotificationName("projectRemoved", object: nil)
            }
        }
    }
    
    
    
    // Mark: ProgressWindowDelegate
    func progressWindowCancelled() {
        self.currentlyRunningTask?.terminate()
    }

    
    
    // MARK: DependencyManagerDelegate
    func startingTask(task: NSTask?) {
        self.currentlyRunningTask = task
    }
    
    
    
    // MARK: Running and stopping server
    @IBAction func toggleServer(sender: AnyObject?) {
        if project?.serverTask != nil {
            stopServer(nil)
            project?.serverStatus = .stopped
        } else if project != nil {
            // Stop all servers
            appDelegate.stopAllServers()
            
            serverOutput = ""
            
            project?.serverStatus = .booting
            
            var ember = EmberCLI()
            let path: String = project!.path!
            project?.serverTask = ember.runServerTask(path)
            var pipe = NSPipe()
            project?.serverTask?.standardOutput = pipe
            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedData:", name:NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading)
            
            project?.serverTask?.terminationHandler = { (task: NSTask!) in
                self.serverTerminated(task, project: self.project)
            }
            project?.serverTask?.launch()
        }
    }
    
    func serverTerminated(task: NSTask, project: Project?) {
        let pipe = task.standardOutput as! NSPipe
        if task.terminationStatus > 0 {
            if project?.serverStatus == .booting { // Ad hoc check for if server was interupted before it started
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    project?.serverStatus = .errored
                    var alert = NSAlert()
                    alert.messageText = "Error starting server"
                    var info = self.serverOutput as NSString
                    if info.length > 400 {
                        info = info.substringToIndex(400)
                    }
                    alert.informativeText = info as String
                    alert.beginSheetModalForWindow(self.mainWindow, completionHandler: nil)
                    self.stopServer(nil)
                })
            }
        }
    }
    
    func receivedData(notification: NSNotification?) {
        var fileHandle = notification?.object as? NSFileHandle
        if let data = fileHandle?.availableData {
            if data.length > 0 {
                fileHandle?.waitForDataInBackgroundAndNotify()
                if let string = NSString(data: data, encoding:NSUTF8StringEncoding) {
                    self.serverOutput += string as String
                    let range = string.rangeOfString("Serving on ")
                    if range.location != NSNotFound {
                        project?.serverStatus = .running
                    }
                }
            } else { // End of file
                NSNotificationCenter.defaultCenter().removeObserver(self, name: NSFileHandleDataAvailableNotification, object: project?.serverTask)
            }
        }
    }
    

    @IBAction func stopServer(sender: AnyObject?) {
        project?.stopServer()
    }
}
