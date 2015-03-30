//
//  ProjectViewController.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 29.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {
    var serverTask: NSTask?
    @IBOutlet var runButton: NSButton!
    @IBOutlet var titleLabel: NSTextField!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setTitle:", name: "activeProjectSet", object: nil)
    }
    
    @IBAction func runServer (sender: AnyObject) {
        if serverTask != nil {
            serverTask!.terminate()
            serverTask = nil
            runButton.title = "Run Ember server"
        } else {
            var appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            if appDelegate.activeProject != nil {
                runButton.title = "Stop Ember server"
                var ember = EmberCLI()
                let project = appDelegate.activeProject!
                let path: String = project["path"] as String
                serverTask = ember.runServer(path)
            }
        }
    }
    
    func setTitle(notification: NSNotification) {
        var appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        self.titleLabel.stringValue = appDelegate.activeProject?["name"] as String
    }
    
    override func viewWillDisappear() {
        println("Closing server")
        serverTask?.terminate()
    }
}
