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
        if self.projects != nil && tempArray == self.projects! {
            return
        }
        self.projects = tempArray
        self.tableView.reloadData()

        var appDelegate = NSApplication.sharedApplication().delegate! as AppDelegate
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
    
    var rowHeight: CGFloat = 50.0
    var textSize: CGFloat = 20.0
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var label = NSTextField()
        label.bezeled = false
        label.editable = false
        label.selectable = false
        label.backgroundColor = NSColor.clearColor()
        var project: Project = projects![row]
        label.stringValue = project.name!
        label.font = NSFont.systemFontOfSize(textSize)
        let labelHeight = textSize + textSize * 0.2
        label.frame = NSMakeRect(0, 0, self.tableView.frame.size.width, labelHeight)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var wrapper = NSTableRowView()
        wrapper.backgroundColor = NSColor.clearColor()
        wrapper.addSubview(label)
        
        let margin = (rowHeight - labelHeight) / 2
        wrapper.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-15-[label]-15-|", options: nil, metrics: nil, views: ["label":label]))
        wrapper.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[label]-margin-|", options: nil, metrics: ["margin":margin], views: ["label":label]))
        return wrapper
    }

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if projects == nil || projects?.count == 0 {
            return
        }
        var project = projects?[tableView.selectedRow]
        if project != nil {
            var appDelegate = NSApplication.sharedApplication().delegate! as AppDelegate
            if appDelegate.activeProject != project {
                appDelegate.activeProject = project!
            }
        }
    }
}
