//
//  ProjectActionsViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 12.04.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectActionsViewController: NSViewController {
    @IBOutlet var buildTypeButton: NSPopUpButton!
    
    var project: Project? {
        get {
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.activeProject
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func build(sender: AnyObject?) {
        if let project = self.project {
            var buildType = buildTypeButton.indexOfSelectedItem == 0 ? EmberBuildType.development : EmberBuildType.production
            
            var ember = EmberCLI()
            ember.build(project.path!, type: buildType, completion: { (result) -> () in
                println("Built with result \(result)")
            })
        }
        
    }
}
