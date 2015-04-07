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
        refreshList(nil)
    }
    
    @IBAction func createNewProject(sender: AnyObject) {
        var appDelegate = NSApplication.sharedApplication().delegate! as AppDelegate
        appDelegate.createNewProject(sender)
    }
    
    @IBAction func openExistingProject(sender: AnyObject) {
        var appDelegate = NSApplication.sharedApplication().delegate! as AppDelegate
        appDelegate.openExistingProject(sender)
    }
    
    func refreshList(notification: NSNotification?) {
        var projectDicts = NSUserDefaults.standardUserDefaults().objectForKey("projects") as? [Dictionary<String, AnyObject>]
        var tempArray: [Project] = []
        if projectDicts != nil {
            for dict in projectDicts! {
                var project = Project(dict: dict)
                tempArray.append(project)
            }
        }
        self.projects = tempArray
        self.tableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        var count = 0
        if projects != nil {
            count = projects!.count
        }
        return count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        var project: Project = projects![row]
        return project.name;
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        var project = projects?[tableView.selectedRow]
        if project != nil {
            var appDelegate = NSApplication.sharedApplication().delegate! as AppDelegate
            appDelegate.activeProject = project!
        }
    }
}
