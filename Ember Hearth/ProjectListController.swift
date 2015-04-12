//
//  ProjectListController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectListController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var overlay: NSImageView!
    @IBOutlet var createProjectButton: NSButton!
    @IBOutlet var openProjectButton: NSButton!
    
    var projects: Array<Project>? {
        set {
            var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
            appDelegate.projects = newValue
            overlay.hidden = projects != nil && appDelegate.projects?.count > 0
            createProjectButton.hidden = overlay.hidden
            openProjectButton.hidden = overlay.hidden
        }
        get {
            var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
            return appDelegate.projects
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList:", name: "activeProjectSet", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList:", name: "projectRemoved", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStarted:", name: "serverStarted", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serverStopped:", name: "serverStopped", object: nil)
        refreshList(nil)
    }
    
    @IBAction func createNewProject(sender: AnyObject) {
        var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.createNewProject(sender)
    }
    
    @IBAction func openExistingProject(sender: AnyObject) {
        var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.openExistingProject(sender)
    }
    
    @IBAction func openInFinder(sender: AnyObject?) {
        let project = projects![tableView.clickedRow]
        let pathURL = NSURL(fileURLWithPath: project.path!)
        NSWorkspace.sharedWorkspace().openURL(pathURL!)
    }
    
    @IBAction func openInTerminal(sender: AnyObject?) {
        let project = projects![tableView.clickedRow]
        NSAppleScript(source: "tell application \"Terminal\" to do script \"cd \(project.path!) && clear\"")?.executeAndReturnError(nil)
    }
    
    @IBAction func delete(sender: AnyObject?) {
        let project = self.projects![tableView.clickedRow]
        
        // Deselect active project if needed
        let delegate = NSApplication.sharedApplication().delegate! as! AppDelegate
        if delegate.activeProject == project {
            let index = indexForProject(project)
            if index > 0 {
                delegate.activeProject = self.projects?[index-1]
            } else if index == 0 && self.projects?.count > 1 {
                delegate.activeProject = self.projects?[index+1]
            } else {
                delegate.activeProject = nil
            }
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
            }
        }
        
        var index: Int? = nil
        
        for (iteratorIndex, aProject) in enumerate(self.projects!) {
            if aProject == project {
                index = iteratorIndex
            }
        }
        
        if let index = index {
            self.projects?.removeAtIndex(index)
            self.tableView.beginUpdates()
            self.tableView.removeRowsAtIndexes(NSIndexSet(index: index), withAnimation: NSTableViewAnimationOptions.SlideUp)
            self.tableView.endUpdates()
        }
    }
    
    func indexForProject(project: Project) -> Int {
        if let projects = self.projects {
            if let result = find(projects, project) {
                return result
            }
        }
        
        return -1
    }
    
    //MARK: Data updating
    func refreshList(notification: NSNotification?) {
        var projectDicts = NSUserDefaults.standardUserDefaults().objectForKey("projects") as? [Dictionary<String, AnyObject>]
        var tempArray: [Project] = []
        if projectDicts != nil {
            for dict in projectDicts! {
                var project = Project(dict: dict)
                tempArray.append(project)
            }
        }
        if self.projects == nil || tempArray != self.projects! {
            self.projects = tempArray
        }
        
        self.tableView.reloadData()

        var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
        let activeProject = appDelegate.activeProject
        if activeProject != nil {
            let indexOfActiveProject = find(self.projects!, activeProject!)
            if indexOfActiveProject != nil {
                self.tableView.selectRowIndexes(NSIndexSet(index: indexOfActiveProject!), byExtendingSelection: false)
            }
        } else {
            appDelegate.activeProject = projects?.first
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let projects = self.projects {
            return projects.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView = tableView.makeViewWithIdentifier("projectCell", owner: tableView) as! NSTableCellView
        var project: Project = projects![row]
        if let name = project.name {
            if project.serverRunning {
                view.textField!.stringValue = "✅ \(name)"
            } else {
                view.textField!.stringValue = "❌ \(name)"
            }
        }
        
        return view
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        if projects == nil || projects?.count == 0 || tableView.selectedRow < 0 {
            return
        }
        if tableView.selectedRow < projects?.count {
            var project = projects?[tableView.selectedRow]
            if project != nil {
                var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
                if appDelegate.activeProject != project {
                    appDelegate.activeProject = project!
                }
            }
        }
    }
    
    //MARK: project state
    func serverStarted(notification: NSNotification?) {
        self.refreshList(notification)
    }
    
    func serverStopped(notification: NSNotification?) {
        self.refreshList(notification)
    }
}
