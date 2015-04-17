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
    @IBOutlet var buildButton: NSButton!
    @IBOutlet var buildingIndicator: NSProgressIndicator!
    
    var project: Project? {
        get {
            var appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.activeProject
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startedBuilding", name: "startedBuilding", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endedBuilding:", name: "endedBuilding", object: nil)
    }
    
    @IBAction func build(sender: AnyObject?) {
        if let project = self.project {
            var buildType = buildTypeButton.indexOfSelectedItem == 0 ? EmberBuildType.development : EmberBuildType.production
            
            var ember = EmberCLI()
            ember.build(project.path!, type: buildType, completion: { (result) -> () in
                
            })
        }
    }
    
    func startedBuilding() {
        self.buildingIndicator.startAnimation(nil)
        self.buildingIndicator.hidden = false
        self.buildButton.enabled = false
    }
    
    func endedBuilding(notification: NSNotification) {
        self.buildingIndicator.stopAnimation(nil)
        self.buildingIndicator.hidden = true
        self.buildButton.enabled = true
        var alert = NSAlert()
        if notification.object != nil {
            alert.messageText = "Success!"
            alert.informativeText = "Build succeeded and was added to the dist folder in the project."
        } else {
            alert.messageText = "Failure"
            alert.informativeText = "Something went wrong while building. Try building manually to see output."
        }
        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
