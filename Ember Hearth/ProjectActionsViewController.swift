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
    
    
    @IBOutlet var testTypeBrowser: NSMenuItem!
    @IBOutlet var testTypeTestem: NSMenuItem!
    @IBOutlet var testTypeButton: NSPopUpButton!
    @IBOutlet var testButton: NSButton!
    
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
    
    
    // MARK: Build actions
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
    
    // MARK: Test actions
    @IBAction func runTests(sender: AnyObject?) {
        if let project = self.project {
            
            let testType: EmberTestType
            if let menuItem = testTypeButton.selectedItem {
                switch menuItem {
                case testTypeBrowser:
                    println("Running tests in browser")
                    testType = .browser
                default:
                    println("Running tests in testem")
                    testType = .testem
                }
            } else {
                println("Running tests in testem (fallback)")
                testType = .testem
            }
            
            var ember = EmberCLI()
            ember.test(project.path!, type: testType)
        }
    }
    
    @IBAction func runTestsOnce(sender: AnyObject?) {
        if let project = self.project {
            var ember = EmberCLI()
            ember.test(project.path!, type: .terminal)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
