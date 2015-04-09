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
        didSet {
            overlay.hidden = projects != nil && projects!.count > 0
            createProjectButton.hidden = overlay.hidden
            openProjectButton.hidden = overlay.hidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshList:", name: "activeProjectSet", object: nil)
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
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        var count = 0
        if projects != nil {
            count = projects!.count
        }
        return count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView = tableView.makeViewWithIdentifier("projectCell", owner: tableView) as! NSTableCellView
        var project: Project = projects![row]
        if project.serverRunning {
            view.textField!.stringValue = "✅ \(project.name!)"
        } else {
            view.textField!.stringValue = "❌ \(project.name!)"
        }
        
        return view
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        if projects == nil || projects?.count == 0 {
            return
        }
        var project = projects?[tableView.selectedRow]
        if project != nil {
            var appDelegate = NSApplication.sharedApplication().delegate! as! AppDelegate
            if appDelegate.activeProject != project {
                appDelegate.activeProject = project!
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
