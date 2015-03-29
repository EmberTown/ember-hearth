//
//  ProjectListController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectListController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func createNewProject(sender: AnyObject) {
        var appDelegate = NSApplication.sharedApplication().delegate! as AppDelegate
        appDelegate.createNewProject(sender)
    }
    
}
