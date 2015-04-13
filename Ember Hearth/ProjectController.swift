//
//  ProjectController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 13.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectController {
    var project: Project? {
        get {
            var delegate = NSApplication.sharedApplication().delegate as? AppDelegate
            return delegate?.activeProject
        }
    }
    
    @IBAction func createProject(sender: AnyObject) {
        
    }
    
    @IBAction func openProject(sender: AnyObject) {
        
    }
    
    @IBAction func runServer(sender: AnyObject) {
        
    }

    @IBAction func stopServer(sender: AnyObject) {
        project?.stopServer()
    }
}
